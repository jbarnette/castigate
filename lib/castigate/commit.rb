module Castigate
  class Commit < Struct.new(:author, :id, :message, :time)
    def to_h
      {
        "author"  => author,
        "id"      => id,
        "message" => message,
        "time"    => time
      }
    end
  end
end
