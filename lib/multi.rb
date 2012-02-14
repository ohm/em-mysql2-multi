require 'mysql2/em'

class Multi
  include EM::Deferrable

  # Set to 1 to see slow queries blocking faster queries
  CONCURRENCY = 5

  attr_reader :pool

  def initialize(pool = Pool.new(CONCURRENCY) { Mysql2::EM::Client.new })
    @pool, @result, @errors = pool, [], []
  end

  def execute(queries)
    @remaining = queries.size

    queries.each do |key, sql|
      pool.execute do |connection|
        connection.query(sql).tap { |query| process(key, query) }
      end
    end
  end

  private

  def process(key, query)
    query.callback do |result|
      check { @result.push([ key, result.to_a ]) }
    end

    query.errback do |error|
      check { @errors.push([ key, error ]) }
    end
  end

  def check(&block)
    yield

    @remaining -= 1
    if @remaining <= 0
      if @errors.empty?
        succeed(Hash[@result])
      else
        fail(Hash[@errors], Hash[@result])
      end
    end
  end
end
