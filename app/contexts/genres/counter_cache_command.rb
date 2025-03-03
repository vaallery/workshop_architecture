class Genres::CounterCacheCommand
  include Callable

  QUERY = <<~SQL
              UPDATE
                genres AS g
              SET
                books_count = (SELECT
                                 COUNT(*)
                               FROM
                                 books_genres AS bg
                               WHERE
                                 bg.genre_id = g.id);
          SQL

  def call
    ActiveRecord::Base.connection.execute(QUERY)
  end
end
