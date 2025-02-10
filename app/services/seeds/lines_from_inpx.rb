class Seeds::LinesFromInpx
  include Callable
  extend Dry::Initializer

  option :files, type: Dry::Types['strict.array']

  def call
    files.each_with_object([]) do |path, lines|
      File.readlines(path, chomp: true).each do |line|
        lines << line
      end
    end
  end
end
