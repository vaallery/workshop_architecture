if (File.exist? Settings.app.sql_dump_path)
  Seeds::SqlDumpLoad.call(filename: Settings.app.sql_dump_path)
  Authors::CounterCacheCommand.call
  Genres::CounterCacheCommand.call
  Keywords::CounterCacheCommand.call
else
  Book.destroy_all
  Seeds::GenreLoad.call(filename: 'db/seeds/genres.yml')
  Seeds::LanguageLoad.call(filename: 'db/seeds/languages.yml')
end

AdminUser.create_with(password: ENV['SEED_EMAIL'])
         .find_or_create_by(email: ENV['SEED_EMAIL'])
