require "flog"

module Castigate
  module Abuse
    class Flog
      def self.columns
        %w(average max size total)
      end

      def abuse commit
        files   = Dir["{app,bin,lib,spec,test}/**/*.rb"]
        flogger = ::Flog.new

        flogger.flog files
        methods = flogger.totals.reject { |k,v| k =~ /\#none$/ }

        {
          :average => flogger.average,
          :max     => methods.values.max,
          :size    => methods.size,
          :total   => flogger.total
        }
      rescue SyntaxError
        nil
      rescue
        nil
      end
    end
  end
end
