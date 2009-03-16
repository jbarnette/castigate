require "grit"
require "castigate/commit"

module Castigate
  module SCM
    class Git
      def self.accept? dir
        File.directory? dir + "/.git"
      end

      def initialize repo
        @repo = repo

        @branch = begin
          head = File.open(@repo.dir + "/.git/HEAD").read.chomp
          $1 if head =~ %r|ref: refs/heads/(.*)|
        end
      end

      def clean?
        s = grit.status
        (s.added | s.changed | s.deleted | s.untracked).empty? && @branch
      end

      def each_commit &block
        commits = grit.commits @branch, false

        Dir.chdir @repo.dir do
          commits.reverse.each do |gc|
            commit = Commit.new gc.author.to_s, gc.id,
              gc.message, gc.date.getutc

            git "checkout", commit.id
            yield commit
          end

          git "clean", "-df"
          git "reset", "--hard"
          git "checkout", @branch
        end
      end

      # FIXME: crap
      def git *args
        cmd = "git #{args.join(' ')} 2>/dev/null"
        ret = `#{cmd}`

        unless $? == 0
          puts "ERROR: Bad result from [#{cmd}]."
          exit $?
        end

        ret
      end

      def grit
        @grit ||= Grit::Repo.new @repo.dir
      end
    end
  end
end
