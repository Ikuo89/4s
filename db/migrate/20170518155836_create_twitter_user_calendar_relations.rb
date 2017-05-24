class CreateTwitterUserCalendarRelations < ActiveRecord::Migration[5.0]
  def up
    create_table :twitter_user_calendar_relations, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.column :calendar_id, 'BIGINT', null: false
      t.column :twitter_user_id, 'BIGINT', null: false

      t.timestamps
    end
    add_foreign_key :twitter_user_calendar_relations, :calendars, on_delete: :cascade
    add_foreign_key :twitter_user_calendar_relations, :twitter_users, on_delete: :cascade
  end

  def down
    drop_table :twitter_user_calendar_relations
  end
end
