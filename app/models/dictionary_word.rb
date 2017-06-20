class DictionaryWord < ApplicationRecord
  class << self
    def insert_if_empty(word)
      self.create(word: word) unless self.exists?(word: word)
    end

    def bulk_insert_pool(word)
      @bulk_insert_items = [] if @bulk_insert_items == nil
      @bulk_insert_items << self.new(:word => word) unless self.exists?(word: word)
    end

    def bulk_insert_items_count
      return 0 unless @bulk_insert_items
      @bulk_insert_items.length
    end

    def bulk_insert_execute
      import(@bulk_insert_items)
      @bulk_insert_items = []
    end
  end
end
