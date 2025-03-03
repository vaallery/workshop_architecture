class Authors::ParseService
  include Callable
  extend Dry::Initializer

  AUTHOR_STRUCTURE = %i[first_name last_name middle_name original]

  option :books, type: Dry::Types['strict.array']
  option :limit, optional: true

  def call
    books.each_with_object([]) do |line, res|
      next if res.count >= limit if limit
      arr = line.split(4.chr)
      res << fio_split(arr[0])
    end
  end

  def fio_split(row_authors)
    authors = row_authors.chomp(':').split(':')&.map(&:strip)&.reject(&:blank?)
    authors.each_with_object([]) do |author, res|
      elements = author.split(',')
      elements = 3.times.each_with_object([]) { |i, res| res << elements[i] } if elements.count < 3
      res << AUTHOR_STRUCTURE.zip(elements.push(author)).to_h
    end
  end
end
