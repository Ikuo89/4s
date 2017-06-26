class RemoveDictionary < ActiveRecord::Migration[5.0]
  def up
    drop_table :dictionary_words if ActiveRecord::Base.connection.table_exists? 'dictionary_words'
  end

  def down
  end
end
