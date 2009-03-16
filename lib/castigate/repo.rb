Dir[File.dirname(__FILE__) + "/scm/*.rb"].each { |f| require f }

module Castigate
  class Repo
    attr_reader :dir

    def initialize dir
      raise dir unless File.directory? dir # FIXME: bad exception
      @dir = File.expand_path dir

      # mix in the appropriate SCM module
      SCM.constants.each do |c|
        klass = SCM.const_get(c)
        if klass.respond_to?(:accept?) && klass.accept?(@dir)
          @scm = klass.new self
          break
        end
      end

      # FIXME: bad exception
      raise "no SCM for #{dir}" unless @scm
    end

    def clean?
      @scm.clean?
    end

    def each_commit &block
      @scm.each_commit &block
    end
  end
end
