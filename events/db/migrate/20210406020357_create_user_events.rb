class CreateUserEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :user_events do |t|
      t.belongs_to :user, null: false, foreign_key: false
      t.string :event_type
      t.json :payload

      t.timestamps
    end
  end
end
