class Keywords::CounterCacheCommand
  include Callable

  QUERY = <<~SQL
              UPDATE
                keywords AS k
              SET
                books_count = (SELECT
                                 COUNT(*)
                               FROM
                                 books_keywords AS bk
                               WHERE
                                 bk.keyword_id = k.id);
          SQL

  def call
    ActiveRecord::Base.connection.execute(QUERY)
  end
end
