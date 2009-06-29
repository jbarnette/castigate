module Castigate
  class Repo
    attr_reader :dir

    def initialize dir
      raise dir unless File.directory? dir # FIXME: bad exception
      @dir = File.expand_path dir

      SCM.constants.each do |c|
        scm = SCM.const_get(c)

        if scm.respond_to?(:accept?) && scm.accept?(@dir)
          extend scm
          break
        end
      end

      # FIXME: bad exceptions
      raise "no SCM for #{dir}" unless respond_to?(:each_commit)
      setup if respond_to? :setup
    end

    def abuse dest = nil
      metrics = Hash.new { |h, k| h[k] = {} }
      # FIXME: load existing metrics

      warn "Abusing #@dir with #{Abuse.constants.join(', ')}." if $DEBUG

      each_commit do |commit|
        metrics[:commit][commit.id] ||= commit.to_h

        Abuse.constants.each do |c|
          klass  = Abuse.const_get(c)
          key    = c.downcase.to_sym
          abuser = klass.new

          # FIXME: only if the abuser hasn't seen this commit
          metrics[key][commit.id] = abuser.abuse(commit)
        end

        $stderr.printf "." if $DEBUG
      end

      warn "" if $DEBUG
      metrics
    end
  end
end
