require "rubygems"
require "hoe"

Hoe.spec "castigate" do
  developer "John Barnette", "jbarnette@rubyforge.org"

  self.extra_rdoc_files = FileList["*.rdoc"]
  self.history_file     = "CHANGELOG.rdoc"
  self.readme_file      = "README.rdoc"
  self.testlib          = :minitest

  extra_deps << ["fastercsv", "~> 1.0"]
  extra_deps << ["flog", "~> 2.0"]
  extra_deps << ["grit", "~> 1.0"]
end
