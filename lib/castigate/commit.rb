module Castigate
  class Commit < Struct.new(:author, :id, :message, :time)
  end
end
