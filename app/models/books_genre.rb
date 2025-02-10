class BooksGenre < ApplicationRecord
  belongs_to :book
  belongs_to :genre, counter_cache: :books_count
end
