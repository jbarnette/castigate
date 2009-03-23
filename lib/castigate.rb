module Castigate
  @@verbose = false

  def self.verbose= flag
    @@verbose = flag
  end

  def self.verbose *messages, &block
    if @@verbose
      $stderr.puts messages.join(" ") unless messages.empty?
      yield $stderr if block_given?
    end
  end
end
