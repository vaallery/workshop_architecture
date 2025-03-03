module LoaderHelpers
  def inp_load_without_links(path)
    database_clear
    load_genres
    load_languages

    lines = File.readlines(path)

    load_folders(lines)
    load_books(lines)
    load_keywords(lines)
    load_authors(lines)
  end

  def inp_full_load(path)
    inp_load_without_links(path)

    lines = File.readlines(path)

    Books::LinksService.call(
      books: lines,
      genres_map: Genre.pluck(:slug, :id).to_h,
      keywords_map: Keyword.pluck(:name, :id).to_h,
      authors_map: Author.pluck(:original, :id).to_h
    )
  end

  def inp_load_genres_langualges_folders(path)
    database_clear
    load_genres
    load_languages

    lines = File.readlines(path)

    load_folders(lines)
  end

  private

  def database_clear
    Keyword.destroy_all
    Book.destroy_all
  end

  def load_genres
    Seeds::GenreLoad.call(filename: 'db/seeds/genres.yml')
  end

  def load_languages
    Seeds::LanguageLoad.call(filename: 'db/seeds/languages.yml')
  end

  def load_folders(lines)
    folders = Folders::ParseService.call(books: lines)
    Folder.create(folders.map { |f| { name: f } })
  end

  def load_books(lines)
    Books::ParseService.call(books: lines)
  end

  def load_keywords(lines)
    keywords = Keywords::ParseService.call(books: lines)
    Keyword.import keywords.uniq.map { |name| Keyword.new(name: name) }
  end

  def load_authors(lines)
    authors = Authors::ParseService.call(books: lines)
    Author.import authors.flatten.uniq.map { |attr| Author.new(attr) }
  end
end
