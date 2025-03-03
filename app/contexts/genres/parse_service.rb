class Genres::ParseService
  include Callable
  extend Dry::Initializer

  option :filename, type: Dry::Types['strict.string']
  option :limit, optional: true

  def call
    read_file.flatten
  end

  def read_file
    File.readlines(filename, chomp: true).each_with_object([]) do |line, res|
      next if res.count >= limit if limit
      arr = line.split(4.chr)
      res << genre_split(arr[1])
    end
  end

  def genre_split(row_genres)
    row_genres.chomp(':').split(':').map(&:strip).reject(&:blank?)
  end
end
