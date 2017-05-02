class CreateUserCalendarsRelations < ActiveRecord::Migration[5.0]
  def up
    create_table :user_calendars_relations, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.column :user_id, 'BIGINT', null: false
      t.column :calendar_id, 'BIGINT', null: false

      t.timestamps
    end
    add_foreign_key :user_calendars_relations, :users, dependent: :delete
    add_foreign_key :user_calendars_relations, :calendars, dependent: :delete
  end

  def down
    drop_table :user_calendars_relations
  end
end
