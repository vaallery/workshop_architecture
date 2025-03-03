class Books::ParseService
  include Callable
  extend Dry::Initializer

  option :books, type: Dry::Types['strict.array']

  attr_reader :authors, :keywords, :folders, :genres, :languages

  def call
    read_file

    true
  end

  def book_attribures(attr, folder_id, language_id)
    {
      title: attr[2],
      series: attr[3],
      serno: attr[4],
      libid: attr[5].to_i,
      size: attr[6].to_i,
      filename: attr[7].to_i,
      del: attr[8] == '1',
      ext: attr[9],
      published_at: attr[10],
      insno: attr[11],
      folder_id: folder_id,
      language_id: language_id
    }
  end

  def folders_map
    @folders ||= Folder.pluck(:name, :id).to_h
  end

  def languages_map
    @languages ||= Language.pluck(:slug, :id).to_h
  end

  def read_file
    attribures = books.each_with_object([]) do |line, association|
                   arr = line.split(4.chr)
                   association << book_attribures(arr, folders_map[arr[12]], languages_map[arr[13]])
                 end
    Book.import(attribures, validate: false)
  end
end
