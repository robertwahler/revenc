# -*- encoding: utf-8 -*-
#
#
Gem::Specification.new do |s|

  # avoid shelling out to run git every time the gemspec is evaluated
  #
  # @see spec/gemspec_spec.rb
  #
  gemfiles_cache = File.join(File.dirname(__FILE__), '.gemfiles')
  if File.exists?(gemfiles_cache)
    gemfiles = File.open(gemfiles_cache, "r") {|f| f.read}
    # normalize EOL
    gemfiles.gsub!(/\r\n/, "\n")
  else
    # .gemfiles missing, run 'rake gemfiles' to create it
    # falling back to 'git ls-files'"
    gemfiles = `git ls-files`
  end

  s.name        = "revenc"
  s.version     = File.open(File.join(File.dirname(__FILE__), 'VERSION'), "r") { |f| f.read }
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Wahler"]
  s.email       = ["robert@gearheadforhire.com"]
  s.homepage    = "http://rubygems.org/gems/revenc"
  s.summary     = "Wrapper for EncFS reverse mounting and folder syncing"
  s.description = "Reverse Mount, unmount, and copy/synchronize encrypted files to untrusted destinations using EncFS and rsync"

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "revenc"

  s.add_dependency 'mutagem', '>= 0.1.3'
  s.add_dependency 'term-ansicolor', '>= 1.0.4'

  s.add_development_dependency "bundler", ">= 1.0.14"
  s.add_development_dependency "rspec", ">= 2.6.0"
  s.add_development_dependency "cucumber", "~> 1.0"
  s.add_development_dependency "aruba", "~> 0.4.2"
  s.add_development_dependency "rake", ">= 0.8.7"

  s.files        = gemfiles.split("\n")
  s.executables  = gemfiles.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_paths = ["lib"]

  s.has_rdoc = 'yard'
  s.rdoc_options     = [
                         '--title', 'Revenc Documentation',
                         '--main', 'README.markdown',
                         '--line-numbers',
                         '--inline-source'
                       ]
end
