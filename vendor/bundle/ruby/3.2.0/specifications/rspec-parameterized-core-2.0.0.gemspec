# -*- encoding: utf-8 -*-
# stub: rspec-parameterized-core 2.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "rspec-parameterized-core".freeze
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/rspec-parameterized/rspec-parameterized-core/blob/main/CHANGELOG.md", "homepage_uri" => "https://github.com/rspec-parameterized/rspec-parameterized-core", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/rspec-parameterized/rspec-parameterized-core" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["sue445".freeze, "tomykaira".freeze, "joker1007".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-05-02"
  s.description = "RSpec::Parameterized supports simple parameterized test syntax in rspec.".freeze
  s.email = ["sue445@sue445.net".freeze, "tomykaira@gmail.com".freeze]
  s.homepage = "https://github.com/rspec-parameterized/rspec-parameterized-core".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "RSpec::Parameterized supports simple parameterized test syntax in rspec. I was inspired by [udzura's mock](https://gist.github.com/1881139).".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rspec>.freeze, [">= 2.13", "< 4"])
  s.add_runtime_dependency(%q<parser>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<proc_to_ast>.freeze, [">= 0.2.0"])
  s.add_runtime_dependency(%q<unparser>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<prism>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 12.0.0"])
  s.add_development_dependency(%q<rspec-its>.freeze, [">= 0"])
end
