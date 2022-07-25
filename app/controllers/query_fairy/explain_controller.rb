# frozen_string_literal: true

module QueryFairy
  class ExplainController < ActionController::Base

    def index
      # query = ActiveRecord::Base.connection.execute("EXPLAIN SELECT * FROM tasks_development.tasks")
      # ActiveRecord::ConnectionAdapters::MySQL::ExplainPrettyPrinter.new.pp(query, [])

      # require 'pry'; binding.pry

      # result_table = QueryFairy.analyze_sql(
      #   "SELECT * FROM tasks_development.tasks",
      #   {analyze: true}
      # )
      #
      # explain  FORMAT = JSON select * from tasks where id < 10 ;
      result_analyze = QueryFairy.analyze_sql(
        "SELECT * FROM tasks_development.tasks where id > 3",
        {analyze: true}
      )
      require 'pry'; binding.pry
    end
  end
end

module QueryFairy
  def self.analyze_sql(raw_sql, opts = {})
    # TODO: maybe we can add a few features here, too
    # prefix = "EXPLAIN #{build_prefix(opts)}"

    prefix = 'EXPLAIN '
    prefix += 'ANALYZE ' if opts[:analyze]

    result = ActiveRecord::Base.connection.execute("#{prefix} #{raw_sql}").to_a

    if [:json, :hash, :pretty_json].include?(opts[:format])
      raw_json = result[0].fetch("EXPLAIN")
      if opts[:format] == :json
        raw_json
      elsif opts[:format] == :hash
        JSON.parse(raw_json)
      elsif opts[:format] == :pretty_json
        JSON.pretty_generate(JSON.parse(raw_json))
      end
    else
      require 'pry'; binding.pry
      result.map do |el|
        el.fetch("EXPLAIN")
      end.join("\n")co
    end
  end

  def self.build_prefix(opts = {})
    format_sql = if fmt = opts[:format].presence
                   case fmt
                   when :json
                     "FORMAT JSON, "
                   when :hash
                     "FORMAT JSON, "
                   when :pretty_json
                     "FORMAT JSON, "
                   when :yaml
                     "FORMAT YAML, "
                   when :text
                     "FORMAT TEXT, "
                   when :xml
                     "FORMAT XML, "
                   else
                     ""
                   end
                 end

    verbose_sql = if opts[:verbose] == true
                    ", VERBOSE"
                  end

    costs_sql = if opts[:costs] == true
                  ", COSTS"
                end

    settings_sql = if opts[:settings] == true
                     ", SETTINGS"
                   end

    buffers_sql = if opts[:buffers] == true
                    ", BUFFERS"
                  end

    timing_sql = if opts[:timing] == true
                   ", TIMING"
                 end

    summary_sql = if opts[:summary] == true
                    ", SUMMARY"
                  end

    analyze_sql = if opts[:analyze] == false
                    ""
                  else
                    "ANALYZE"
                  end

    opts_sql = "(#{format_sql}#{analyze_sql}#{verbose_sql}#{costs_sql}#{settings_sql}#{buffers_sql}#{timing_sql}#{summary_sql})"
                 .strip.gsub(/\s+/, " ")
                 .gsub(/\(\s?\s?\s?,/, "(")
                 .gsub(/\s,\s/, " ")
                 .gsub(/\(\s?\)/, "")
  end
end


module ActiveRecord
  module ConnectionAdapters
    module MySQL
      module DatabaseStatements
        def analyze(arel, binds = [], opts = {})
          opts_sql = ActiveRecordAnalyze.build_prefix(opts)

          sql = "EXPLAIN #{opts_sql} #{to_sql(arel, binds)}"
          ActiveRecord::ConnectionAdapters::MySQL::ExplainPrettyPrinter.new.pp(
            exec_query(sql, "EXPLAIN #{opts_sql}".strip, binds)
          )
        end
      end
    end
  end
end

module ActiveRecord
  class Relation
    def analyze(opts = {})
      res = exec_analyze(collecting_queries_for_explain { exec_queries }, opts)
      if [:json, :hash, :pretty_json].include?(opts[:format])
        start = res.index("[\n")
        finish = res.rindex("]")
        raw_json = res.slice(start, finish - start + 1)

        if opts[:format] == :json
          JSON.parse(raw_json).to_json
        elsif opts[:format] == :hash
          JSON.parse(raw_json)
        elsif opts[:format] == :pretty_json
          JSON.pretty_generate(JSON.parse(raw_json))
        end
      else
        res
      end
    end
  end
end

module ActiveRecord
  module Explain
    def exec_analyze(queries, opts = {}) # :nodoc:
      str = queries.map do |sql, binds|
        analyze_msg = if opts[:analyze] == false
                        ""
                      else
                        " ANALYZE"
                      end

        msg = "EXPLAIN#{analyze_msg} for: #{sql}".dup
        unless binds.empty?
          msg << " "
          msg << binds.map { |attr| render_bind(attr) }.inspect
        end
        msg << "\n"
        msg << connection.analyze(sql, binds, opts)
      end.join("\n")

      # Overriding inspect to be more human readable, especially in the console.
      def str.inspect
        self
      end

      str
    end
  end
end