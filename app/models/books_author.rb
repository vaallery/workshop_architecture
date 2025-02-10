class BooksAuthor < ApplicationRecord
  belongs_to :book
  belongs_to :author, counter_cache: :books_count
end
