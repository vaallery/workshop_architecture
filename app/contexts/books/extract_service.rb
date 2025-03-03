class Books::ExtractService
  include Callable
  extend Dry::Initializer

  option :id, type: Dry::Types['strict.string']

  def call
    extract

    {
      tempfile: "#{extract_folder}#{book.filename}.#{book.ext}",
      filename: "#{book.title}.#{book.ext}"
    }
  end

  private

  def book
    @book ||= Book.find(id)
  end

  def extract
    Zip::File.open("#{archives_folder}#{book.folder.name}") do |zip_file|
      FileUtils.mkdir_p(extract_folder)
      entry = zip_file.find_entry("#{book.filename}.#{book.ext}")
      FileUtils.rm_rf("#{extract_folder}#{book.filename}.#{book.ext}", secure: true)
      zip_file.extract(entry, "#{extract_folder}#{book.filename}.#{book.ext}")
    end
  end

  def archives_folder
    Settings.app.archives_folder
  end

  def extract_folder
    Settings.app.extract_folder
  end
end
