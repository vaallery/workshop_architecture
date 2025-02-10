class BooksKeyword < ApplicationRecord
  belongs_to :book
  belongs_to :keyword, counter_cache: :books_count
end
