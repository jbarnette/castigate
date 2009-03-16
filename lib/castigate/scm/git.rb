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
        (s.added | s.changed | s.deleted).empty? && @branch
      end

      def commits
        @commits ||= begin
          commits, offset = [], 0

          # grit dies a horrible death without pagination
          until (chunk = grit.commits(@branch, 100, offset)).empty?
            offset = offset + 100
            commits.concat chunk
          end

          commits.reverse.collect do |gc|
            commit = Commit.new gc.author.to_s, gc.id,
              gc.message, gc.date.getutc
          end
        end
      end

      def each_commit &block
        Dir.chdir @repo.dir do
          commits.each do |commit|
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
