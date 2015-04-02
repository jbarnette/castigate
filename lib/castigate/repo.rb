module Castigate
  class Cache
    def self.cache path, data = {}
      data = read(path) if File.exist? path
      yield data
      data
    ensure
      write path, data
    end

    def self.read path
      File.open path do |f|
        Marshal.load f
      end
    end

    def self.write path, data
      File.open(path, "w") do |f|
        data.default_proc = nil if Hash === data
        Marshal.dump data, f
      end
    end
  end

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
      cache_name = "#{File.basename(@dir)}.cache"

      Cache.cache cache_name do |metrics|
        metrics.default_proc = lambda { |h, k| h[k] = {} } # hack?

        warn "Abusing #@dir with #{Abuse.constants.join(', ')}." if $DEBUG

        each_commit do |commit|
          metrics[:commit][commit.id] ||= commit.to_h

          Abuse.constants.each do |c|
            klass  = Abuse.const_get(c)
            key    = c.downcase.to_sym

            next if metrics[key][commit.id]

            abuser = klass.new

            checkout commit
            metrics[key][commit.id] ||= abuser.abuse(commit)
          end

          $stderr.printf "." if $DEBUG
        end

        warn "" if $DEBUG

        metrics
      end
    end
  end
end
