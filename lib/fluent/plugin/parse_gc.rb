module Fluent
  class TextParser
    class GCParser < Parser
      include Configurable

      config_param :time_key, :string, :default => 'time'

      def configure(conf={})
        super
      end

      def parse(text)
        record = {}
        record["metric"] = "cassandra.gc.duration"
        if match = text.match(/GC in (.*)ms/)
          duration = match.captures[0].to_i
        end
        record["value"] = duration

        time = record.delete(@time_key)
        if time.nil?
          time = Engine.now
        elsif time.respond_to?(:to_i)
          time = time.to_i
        else
          raise RuntimeError, "The #{@time_key}=#{time} is a bad time field"
        end

        yield time, record
      end
    end
    register_template('cassandra', Proc.new { GCParser.new })
  end
end
