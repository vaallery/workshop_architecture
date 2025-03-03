class Authors::CounterCacheCommand
  include Callable

  QUERY = <<~SQL
              UPDATE
                authors AS a
              SET
                books_count = (SELECT
                                 COUNT(*)
                               FROM
                                 books_authors AS ba
                               WHERE
                                 ba.author_id = a.id);
          SQL

  def call
    ActiveRecord::Base.connection.execute(QUERY)
  end
end
