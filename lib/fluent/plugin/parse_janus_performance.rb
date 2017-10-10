module Fluent
  class TextParser
    class JanusPerformanceParser < Parser
      include Configurable

      config_param :time_key, :string, :default => 'time'

      def configure(conf={})
        super
      end

      def parse(text)
        record = {}
        if match = text.match(/1-minute rate = (.*) calls\/second/)
          calls = match.captures[0].to_f
          record["metric"] = "janus.performance.calls"
          record["value"] = calls
        end

        if match = text.match(/75% <= (.*) milliseconds/)
          duration = match.captures[0].to_f
          record["metric"] = "janus.performance.75_percentile"
          record["value"] = duration
        end

        if match = text.match(/95% <= (.*) milliseconds/)
          duration = match.captures[0].to_f
          record["metric"] = "janus.performance.95_percentile"
          record["value"] = duration
        end

        if match = text.match(/99.9% <= (.*) milliseconds/)
          duration = match.captures[0].to_f
          record["metric"] = "janus.performance.99dot9_percentile"
          record["value"] = duration
        end

        time = record.delete(@time_key)
        if time.nil?
          time = Engine.now
        elsif time.respond_to?(:to_i)
          time = time.to_i
        else
          raise RuntimeError, "The #{@time_key}=#{time} is a bad time field"
        end

        if record["value"] && record["value"] > 0.0
          yield time, record
        end
      end
    end
    register_template('janusgraph', Proc.new { JanusPerformanceParser.new })
  end
end
