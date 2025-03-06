class BooksController < ApplicationController
  def index
    books = paginate(Book.all)
    render json: BookSerializer.new(books)
  end
end
