class BooksController < ApplicationController
  def index
    books = Book.search(params.fetch(:search, ''), fields: ["insno^10", "title"], **pagination_params)

    # Вариант, если придется миксовать условия поиска
    # book_ids = Book.search(params.fetch(:search, ''), fields: ["insno^10", "title"], load: false, **pagination_params).ids
    # books = Book.where(id: book_ids)

    render json: BookSerializer.new(books)
  end
end
