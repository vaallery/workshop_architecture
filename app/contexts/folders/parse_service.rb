class Folders::ParseService
  include Callable
  extend Dry::Initializer

  option :books, type: Dry::Types['strict.array']
  option :limit, optional: true

  def call
    books.each_with_object([]) do |line, res|
      next if res.count >= limit if limit
      arr = line.split(4.chr)
      res << arr[12]
    end
  end
end
