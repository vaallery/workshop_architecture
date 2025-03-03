namespace :inpx do
  desc 'Извлекаем содержимое inpx-файла'
  task :ls, [ :path ] => [ :environment ] do |task, args|
    args.with_defaults(path: ENV.fetch('INPX_PATH', 'db/data/archive.inpx'))
    Zip::File.open(args[:path]) do |zip_file|
      zip_file.each do |entry|
        puts "#{entry.name}: #{entry.size}"
      end
    end
  end

  desc 'Перестриваем базу данных по inpx-индексу'
  task :rebuild, [ :path ] => [ :environment ] do |task, args|
    start = Time.zone.now
    args.with_defaults(path: ENV.fetch('INPX_PATH', 'db/data/archive.inpx'))

    FileUtils.rm_rf('tmp/extracts/.', secure: true)
    FileUtils.mkdir_p('tmp/extracts')

    Zip::File.open(args[:path]) do |zip_file|
      zip_file.each do |entry|
        entry.extract("tmp/extracts/#{entry}")
      end
    end

    Book.destroy_all
    Seeds::GenreLoad.call(filename: 'db/seeds/genres.yml')
    puts "Жанры #{Genre.count}"
    Seeds::LanguageLoad.call(filename: 'db/seeds/languages.yml')
    puts "Языки #{Language.count}"

    regexp_files = /\Atmp\/extracts\/(usr|fb2)-(ru|en)/
    files = Dir.glob('tmp/extracts/*.inp').select { |entry| entry =~ regexp_files }

    files_count = Dir.glob('tmp/extracts/*.inp').count
    puts "Общее количество inp-файлов #{files_count}"
    puts "Отобранных для развертывания inp-файлов #{files.count}"

    lines = Seeds::LinesFromInpx.call(files: files)
    count = Settings.app.index_concurrent_processes
    chunks = lines.in_groups(count, false)
    pp chunks.count

    title = 'Папки'
    puts title
    folders = Parallel.map(Range.new(0, count - 1), in_processes: count) do |index|
                start = Time.zone.now
                folders = Folders::ParseService.call(books: chunks[index])
                finish = Time.zone.now
                puts format("Процесс %d: %0.2f сек", index, (finish - start))
                folders.uniq
              end
    Folder.import folders.flatten.uniq.map { |f| { name: f } }, validate: false
    puts "#{title} #{Folder.count}"

    title = 'Книги'
    puts title
    Parallel.map(Range.new(0, count - 1), in_processes: count) do |index|
      start = Time.zone.now
      Books::ParseService.call(books: chunks[index])
      finish = Time.zone.now
      puts format("Процесс %d: %0.2f сек", index, (finish - start))
    end
    puts "#{title} #{Book.count}"

    title = 'Авторы'
    puts title
    authors = Parallel.map(Range.new(0, count - 1), in_processes: count) do |index|
                start = Time.zone.now
                authors = Authors::ParseService.call(books: chunks[index])
                finish = Time.zone.now
                puts format("Процесс %d: %0.2f сек", index, (finish - start))
                authors.flatten.uniq
              end
    Author.import authors.flatten.uniq, validate: false
    puts "#{title} #{Author.count}"

    title = 'Ключевые слова'
    puts title
    keywords = Parallel.map(Range.new(0, count - 1), in_processes: count) do |index|
                start = Time.zone.now
                keywords = Keywords::ParseService.call(books: chunks[index])
                finish = Time.zone.now
                puts format("Процесс %d: %0.2f сек", index, (finish - start))
                keywords.uniq
              end
    Keyword.import keywords.flatten.uniq.map { |f| { name: f } }, validate: false
    puts "#{title} #{Keyword.count}"

    puts 'Связи'

    # TODO видимо тут не хватает сервис-объекта
    genres_map = Genre.pluck(:slug, :id).to_h
    keywords_map = Keyword.pluck(:name, :id).to_h
    authors_map = Author.pluck(:original, :id).to_h

    Parallel.map(Range.new(0, count - 1), in_processes: count) do |index|
      start = Time.zone.now
      Books::LinksService.call(
        books: chunks[index],
        genres_map: genres_map,
        keywords_map: keywords_map,
        authors_map: authors_map
      )
      finish = Time.zone.now
      puts format("Процесс %d: %0.2f сек", index, (finish - start))
    end

    Authors::CounterCacheCommand.call
    Genres::CounterCacheCommand.call
    Keywords::CounterCacheCommand.call
    Languages::CounterCacheCommand.call

    puts "Связей книг и авторов #{BooksAuthor.count}"
    puts "Связей книг и ключевых слов #{BooksKeyword.count}"
    puts "Связей книг и жанров #{BooksGenre.count}"

    FileUtils.rm_rf('tmp/extracts/.', secure: true)
    puts "Время создания индекса #{Time.zone.now - start}"
  end
end
