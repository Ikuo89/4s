class CreateTwitterTweets < ActiveRecord::Migration[5.0]
  def up
    create_table :twitter_tweets, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.column :twitter_user_id, 'BIGINT', null: false
      t.string :text, null: false

      t.timestamps
    end
    add_foreign_key :twitter_tweets, :twitter_users, on_delete: :cascade
  end
  def down
    drop_table :twitter_tweets
  end
end
