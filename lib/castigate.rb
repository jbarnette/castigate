require "rubygems"

module Castigate
  VERSION = "1.0.0"

  # All the abuse plugins live under this module.

  module Abuse
  end

  # All the SCM plugins live under this module.

  module SCM
  end
end

# load plugins
unless defined?(LOADED_CASTIGATE_PLUGINS) then
  LOADED_CASTIGATE_PLUGINS = true
  Gem.find_files("castigate/{abuse,scm}/*.rb").each { |f| require f }
end
