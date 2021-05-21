class User < ApplicationRecord
  has_many :events, class_name: 'Events::User::BaseEvent'

  default_scope { where.not(deleted: true) }
end
