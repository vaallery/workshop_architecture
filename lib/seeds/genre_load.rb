class Seeds::GenreLoad
  include Callable
  extend Dry::Initializer

  option :filename, type: Dry::Types['strict.string']

  def call
    truncate_tables %w[books_genres genre_groups genres]
    GenreGroup.create! seeds_from_yaml(filename)
  end

  def truncate_tables(tables)
    ActiveRecord::Base.connection.execute("TRUNCATE #{tables.join(',')}") unless tables.empty?
  end

  def seeds_from_yaml(file)
    YAML.load_file(Rails.root.join(file))['items'] || []
  end
end
