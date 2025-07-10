# -*- encoding: utf-8 -*-
# stub: rake-hooks 1.2.3 ruby lib

Gem::Specification.new do |s|
  s.name = "rake-hooks".freeze
  s.version = "1.2.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Guillermo \u00C1lvarez".freeze, "Joel Moss".freeze]
  s.date = "2011-12-01"
  s.description = "Add after and before hooks to rake tasks. You can use \"after :task do ... end\" and \"before :task do ... end\".".freeze
  s.email = ["guillermo@cientifico.net".freeze, "joel@developwithstyle.com".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Add after and before hooks to rake tasks".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 3

  s.add_runtime_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
end
