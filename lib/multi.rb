class Multi
  include EM::Deferrable

  attr_reader :pool

  def initialize(pool)
    @pool = pool
  end

  def execute(queries)
    remaining, result = queries.size, []

    queries.each do |key, sql|
      pool.execute do |client|
        client.query(sql).tap do |query|
          query.callback do |r|
            remaining -= 1
            result << [ key, r.to_a ]
            succeed(Hash[result]) if remaining <= 0
          end
        end
      end
    end
  end
end
