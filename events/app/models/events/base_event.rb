class Events::BaseEvent < ActiveRecord::Base
  before_validation :find_or_build_aggregate
  before_save :apply_and_persist

  self.abstract_class = true

  def apply(aggregate)
    raise NotImplementedError
  end

  def self.hydrate(date: nil, range: nil, in_memory: false)
    if date
      events = all.where('created_at <= ?', date)
    elsif range
      ids = begin
        range.to_a
      rescue RangeError
        (range.first..maximum(:id)).to_a
      end

      events = all.where(id: ids)
    end

    aggregates = events.each_with_object({}) do |event, hash|
      klass = "Events::User::#{event.event_type}".safe_constantize
      event = event.becomes(klass)

      # hash[event.key] = in_memory ? event.apply_in_memory(hash[event.key]) : event.save
      hash[event.key] = event.apply_in_memory(hash[event.key])
    end.values

    unless in_memory
      aggregates.each do |aggregate|
        aggregate.save
      end
    end

    aggregates
  end

  def apply_in_memory(in_memory_aggregate)
    if in_memory_aggregate.nil?
      in_memory_aggregate = build_aggregate
    end

    self.aggregate = apply(in_memory_aggregate)
  end

  # key used for building in memory records
  def key
    "build" if new_record?
  end

  after_initialize do
    self.event_type = event_type
    self.payload ||= {}
  end

  def self.payload_attributes(*attributes)
    @payload_attributes ||= []

    attributes.map(&:to_s).each do |attribute|
      @payload_attributes << attribute unless @payload_attributes.include?(attribute)

      define_method attribute do
        self.payload ||= {}
        self.payload[attribute]
      end

      define_method "#{attribute}=" do |argument|
        self.payload ||= {}
        self.payload[attribute] = argument
      end
    end

    @payload_attributes
  end

  private def find_or_build_aggregate
    self.aggregate = find_aggregate if aggregate_id.present?
    self.aggregate = build_aggregate if self.aggregate.nil?
  end

  def find_aggregate
    klass = aggregate_name.to_s.classify.constantize
    klass.find(aggregate_id)
  end

  def build_aggregate
    public_send "build_#{aggregate_name}"
  end

  private def apply_and_persist
    # Lock the database row! (OK because we're in an ActiveRecord callback chain transaction)
    aggregate.lock! if aggregate.persisted?

    # Apply!
    self.aggregate = apply(aggregate)

    #Persist!
    aggregate.save!
    self.aggregate_id = aggregate.id if aggregate_id.nil?
  end

  def aggregate=(model)
    public_send "#{aggregate_name}=", model
  end

  def aggregate
    public_send aggregate_name
  end

  def aggregate_id=(id)
    public_send "#{aggregate_name}_id=", id
  end

  def aggregate_id
    public_send "#{aggregate_name}_id"
  end

  def self.aggregate_name
    inferred_aggregate = reflect_on_all_associations(:belongs_to).first
    raise "Events must belong to an aggregate" if inferred_aggregate.nil?
    inferred_aggregate.name
  end

  delegate :aggregate_name, to: :class

  def event_type
    self.attributes["event_type"] || self.class.to_s.split("::").last
  end

  def event_klass
    klass = self.class.to_s.split("::")
    klass[-1] = event_type
    klass.join('::').constantize
  end
end
