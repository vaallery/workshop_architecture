class Languages::CounterCacheCommand
  include Callable

  QUERY = <<~SQL
              UPDATE
                languages AS l
              SET
                books_count = (SELECT
                                 COUNT(*)
                               FROM
                                 books AS b
                               WHERE
                                 b.language_id = l.id);
          SQL

  def call
    ActiveRecord::Base.connection.execute(QUERY)
  end
end
