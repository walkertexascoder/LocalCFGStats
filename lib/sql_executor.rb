module SqlExecutor

  class SqlError < RuntimeError

    def initialize(parent, sql)
      @parent = parent
      @sql = sql
    end

    attr_reader :parent, :sql

  end

  def analyze_sql(sql)
    execute_sql("explain (analyze true, buffers true, verbose true, format json) #{sql}").map do |row|
      row.first # drop the "explain" prefix
    end.join.gsub(/\s+/, ' ')
  end

  def execute_sql(sql)
    begin
      ActiveRecord::Base.connection.execute(sql).values
    rescue
      raise SqlExecutor::SqlError.new($!, sql)
    end
  end

  def benchmark_sql(sql)
    result = nil

    measure = Benchmark.measure do
      result = execute_sql(sql)
    end
    puts "#{measure.real}s"

    result
  end

end