require "rubygems"
require "hoe"

require "./lib/castigate/version.rb"

Hoe.new "castigate", Castigate::VERSION do |p|
  p.developer "John Barnette", "jbarnette@rubyforge.org"

  p.url              = "http://github.com/jbarnette/castigate"
  p.history_file     = "CHANGELOG.rdoc"
  p.readme_file      = "README.rdoc"
  p.extra_rdoc_files = [p.readme_file]
  p.need_tar         = false
  p.test_globs       = %w(test/**/*_test.rb)
  p.testlib          = :minitest

  p.extra_deps << ["fastercsv", "~> 1.0"]
  p.extra_deps << ["flog", "~> 2.0"]
  p.extra_deps << ["grit", "~> 1.0"]
end
