class CreateDictionaryWords < ActiveRecord::Migration[5.0]
  def up
    create_table :dictionary_words, id: false do |t|
      t.column :id, 'BIGINT PRIMARY KEY AUTO_INCREMENT'
      t.string :word, null: false

      t.timestamps null: false
    end
    add_index :dictionary_words, [:word], unique: true
  end

  def down
    drop_table :dictionary_words
  end
end
