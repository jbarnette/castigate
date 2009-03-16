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
end
