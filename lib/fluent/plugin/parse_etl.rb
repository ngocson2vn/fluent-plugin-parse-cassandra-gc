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
        if match = text.match(/Added \(Edges\/Vertices\) (.*)\/(.*)/)
          edges = match.captures[0].to_i
          vertices = match.captures[1].to_i
          record["metric"] = "graph_etl.add.count"
          record["value"] = edges + vertices
        end

        if match = text.match(/Updated \(Edges\/Vertices\) (.*)\/(.*)/)
          edges = match.captures[0].to_i
          vertices = match.captures[1].to_i
          record["metric"] = "graph_etl.update.count"
          record["value"] = edges + vertices
        end

        time = record.delete(@time_key)
        if time.nil?
          time = Engine.now
        elsif time.respond_to?(:to_i)
          time = time.to_i
        else
          raise RuntimeError, "The #{@time_key}=#{time} is a bad time field"
        end

        if record["value"]
          yield time, record
        end
      end
    end
    register_template('graph_etl', Proc.new { JanusPerformanceParser.new })
  end
end
