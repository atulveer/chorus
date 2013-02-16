require 'sequel'

class DataSourceConnection
  class Error < StandardError
    def initialize(exception = nil)
      if exception
        super(exception.message)
        @exception = exception
      end
    end

    def to_s
      sanitize_message super
    end

    def message
      sanitize_message super
    end

    private

    def sanitize_message(message)
      message
    end
  end

  class QueryError < StandardError; end

  def fetch(sql, parameters = {})
    with_connection { @connection.fetch(sql, parameters).all }
  end

  def fetch_value(sql)
    with_connection { @connection.fetch(sql).single_value }
  end

  def execute(sql)
    with_connection { @connection.execute(sql) }
    true
  end

  def stream_dataset(dataset, limit = nil, &block)
    stream_sql(dataset.all_rows_sql, limit, &block)
  end

  def stream_sql(sql, limit = nil)
    with_connection do
      @connection.synchronize do |jdbc_conn|
        jdbc_conn.set_auto_commit(false)

        stmnt = jdbc_conn.create_statement
        stmnt.set_fetch_size(1000)
        stmnt.set_max_rows(limit) if limit

        result_set = stmnt.execute_query(sql)
        column_number = result_set.meta_data.column_count

        while(result_set.next) do
          record = {}

          column_number.times do |i|
            record[result_set.meta_data.column_name(i+1).to_sym] = result_set.get_string(i+1)
          end

          yield record
        end

        result_set.close
        jdbc_conn.close
      end
    end

    true
  end
end