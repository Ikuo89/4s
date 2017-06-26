class ChangeTextToLongtext < ActiveRecord::Migration[5.0]
  def up
    change_column :line_room_talks, :text, :text, null: false, limit: 16777215
  end
  def down
  end
end
