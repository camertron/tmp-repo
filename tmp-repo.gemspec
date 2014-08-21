$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'tmp-repo/version'  

Gem::Specification.new do |s|
  s.name     = "tmp-repo"
  s.version  = ::TmpRepo::VERSION
  s.authors  = ["Cameron Dutro"]
  s.email    = ["camertron@gmail.com"]
  s.homepage = "http://github.com/camertron"

  s.description = s.summary = "Creates and manages a git repository in the operating system's temporary directory. Useful for running git operations in tests."

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.require_path = 'lib'
  s.files = Dir["{lib,spec}/**/*", "Gemfile", "History.txt", "README.md", "Rakefile", "tmp-repo.gemspec"]
end
