$verbose ||= false

%w(abuse scm).each do |dir|
  Dir[File.dirname(__FILE__) + "/#{dir}/*.rb"].each { |f| require f }
end

module Castigate
  class Repo
    ABUSERS = {}
    COLUMNS = %w(commit_author commit_id commit_time)

    Abuse.constants.each do |c|
      klass = Abuse.const_get(c)
      name = klass.name.split("::").last.downcase
      ABUSERS[name] = klass.new
      COLUMNS.concat klass.columns.collect { |c| "#{name}_#{c}" }
    end

    COLUMNS.sort!

    attr_reader :dir

    def initialize dir
      raise dir unless File.directory? dir # FIXME: bad exception
      @dir = File.expand_path dir

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

    def abuse
      $stderr.printf "Abusing #{commits.size} commits with " +
        "#{ABUSERS.keys.join', '}: " if $verbose

      results = []

      each_commit do |commit|
        row = {
          :commit_author => commit.author,
          :commit_id     => commit.id,
          :commit_time   => commit.time,
        }

        $stderr.printf "." if $verbose

        ABUSERS.each do |name, abuser|
          result = abuser.abuse commit
          result.each { |k, v| row[:"#{name}_#{k}"] = v } if result
        end

        results << row
      end

      $stderr.puts if $verbose
      results
    end

    def clean?
      @scm.clean?
    end

    def commits
      @scm.commits
    end

    def each_commit &block
      @scm.each_commit &block
    end
  end
end
