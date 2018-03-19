require File.expand_path("../lib/vagrant-cloudcenter/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "vagrant-cloudcenter"
  s.version     = "0.4.0"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Conor Murphy"]
  s.email       = ["conormurphy33@hotmail.com"]
  s.summary     =  "A vagrant provider plugin for Cisco Cloud Center"
  s.description = "NA"

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md","{locales}/*.yml","../{locales}/*.yml","locales/*.yml"]
  s.require_path = 'lib'

  s.add_runtime_dependency 'highline'
  s.add_runtime_dependency 'colorize'
  s.add_runtime_dependency 'rest-client'
  s.add_runtime_dependency 'json'
  s.add_runtime_dependency 'text-table'

end