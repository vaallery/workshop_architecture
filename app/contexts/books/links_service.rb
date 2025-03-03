class Books::LinksService
  include Callable
  extend Dry::Initializer

  option :books, type: Dry::Types['strict.array']
  option :genres_map, type: Dry::Types['strict.hash']
  option :keywords_map, type: Dry::Types['strict.hash']
  option :authors_map, type: Dry::Types['strict.hash']

  def call
    books_tree = list_books(books)
    genres(books, books_tree)
    keywords(books, books_tree)
    authors(books, books_tree)
  end

  def list_books(books)
    books_collection = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = [] } }

    books.each_with_object(books_collection) do |line, books|
      arr = line.split(4.chr)
      book = Book.find_by(folder_id: folders_map[arr[12]], filename: arr[7].to_i)
      books[arr[12]][arr[7].to_i] = book.id
    end
  end

  def folders_map
    @folders ||= Folder.pluck(:name, :id).to_h
  end

  def base_link(books)
    readfile(books) do |line|
      yield line.split(4.chr)
    end
  end

  def genres(books, books_tree)
    links = base_link(books) do |arr|
              book_genres(arr[1], books_tree[arr[12]][arr[7].to_i])
            end
    BooksGenre.import links.flatten.uniq, validate: false
  end

  def keywords(books, books_tree)
    links = base_link(books) do |arr|
              book_keywords(arr[15], books_tree[arr[12]][arr[7].to_i])
            end
    BooksKeyword.import links.flatten.uniq, validate: false
  end

  def authors(books, books_tree)
    links = base_link(books) do |arr|
              book_authors(arr[0], books_tree[arr[12]][arr[7].to_i])
            end
    BooksAuthor.import links.flatten.uniq, validate: false
  end

  def book_genres(genres, book_id)
    genres = genres.chomp(':').split(':').map(&:strip).reject(&:blank?)
    genres.map do |genre|
      { book_id: book_id, genre_id: genres_map[genre] }
    end
  end

  def book_keywords(keywords, book_id)
    keywords = keywords&.chomp(',')&.split(',')&.map(&:strip)&.reject(&:blank?) || []
    keywords.map do |keyword|
      { book_id: book_id, keyword_id: keywords_map[keyword] }
    end
  end

  def book_authors(authors, book_id)
    authors = authors.chomp(':').split(':').map(&:strip).reject(&:blank?)
    authors.select { |author| authors_map[author] }.map do |author|
      { book_id: book_id, author_id: authors_map[author] }
    end
  end

  def readfile(books, results = [])
    books.each_with_object(results) do |line, results|
      results.push(*yield(line))
    end
  end
end
