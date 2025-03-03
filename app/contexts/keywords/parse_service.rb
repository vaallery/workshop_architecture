class Keywords::ParseService
  include Callable
  extend Dry::Initializer

  option :books, type: Dry::Types['strict.array']
  option :limit, optional: true

  def call
    read_file.flatten.map(&:strip)
  end

  def read_file
    books.each_with_object([]) do |line, res|
      next if res.count >= limit if limit
      arr = line.split(4.chr)
      res << keywords_split(arr[15])
    end
  end

  def keywords_split(row_keywords)
    row_keywords&.chomp(',')&.split(',')&.map(&:strip)&.reject(&:blank?) || []
  end
end
