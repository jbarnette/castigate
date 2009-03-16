module Castigate
  module Abuse
    class Files
      def self.columns
        %w(count)
      end

      def abuse commit
        { :count => `find . -type f | wc -l`.to_i }
      end
    end
  end
end
