require "castigate/commit"

module Castigate
  module SCM
    module Git
      class Repo
        attr_accessor :dir
        def initialize dir
          self.dir = dir
        end

        def clean?
          `git status --all`.include? "nothing to commit, working directory clean"
        end

        def commits(*)
          Dir.chdir dir do
            `git log --pretty=format:"%h|%an|%ai|%s"`.lines.map { |l| l.chomp.split(/\|/, 4) }
          end
        end
      end

      def self.accept? dir
        File.directory? dir + "/.git"
      end

      def setup
        @branch = begin
          head = File.open(@dir + "/.git/HEAD").read.chomp
          $1 if head =~ %r|ref: refs/heads/(.*)|
        end

        @repo = Repo.new @dir
        @current = nil
      end

      def clean?
         @repo.clean? && @branch
      end

      def commits
        @commits ||= begin
          commits = @repo.commits

          commits.reverse.collect do |gc|
            id, author, date, title = gc
            Commit.new author, id, title, date
          end
        end
      end

      def checkout commit
        return if commit.id == @current
        warn commit.time
        git "checkout", commit.id
        @current = commit.id
      end

      def each_commit &block
        Dir.chdir @dir do
          begin
            commits.each do |commit|
              yield commit
            end
          ensure
            git "clean", "-df"
            git "reset", "--hard"
            git "checkout", @branch
          end
        end
      end

      # FIXME: crap
      def git *args
        cmd = "git #{args.join(' ')} 2>/dev/null"
        ret = `#{cmd}`

        unless $? == 0
          puts "ERROR: Bad result from [#{cmd}]: #{ret}"
          exit 1
        end

        ret
      end
    end
  end
end
