# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{octocat_herder}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Jacob Helwig}]
  s.date = %q{2011-10-17}
  s.description = %q{This gem provides Ruby bindings to the v3 GitHub API}
  s.email = %q{jacob@technosorcery.net}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.markdown"
  ]
  s.files = [
    ".document",
    ".travis.yml",
    "CONTRIBUTING.markdown",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.markdown",
    "Rakefile",
    "VERSION",
    "lib/octocat_herder.rb",
    "lib/octocat_herder/base.rb",
    "lib/octocat_herder/connection.rb",
    "lib/octocat_herder/pull_request.rb",
    "lib/octocat_herder/pull_request/repo.rb",
    "lib/octocat_herder/repository.rb",
    "lib/octocat_herder/user.rb",
    "octocat_herder.gemspec",
    "spec/octocat_herder/connection_spec.rb",
    "spec/octocat_herder_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/jhelwig/octocat_herder}
  s.licenses = [%q{BSD}]
  s.require_paths = [%q{lib}]
  s.rubygems_version = %q{1.8.6}
  s.summary = %q{An interface to the v3 GitHub API}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httparty>, ["~> 0.7.8"])
      s.add_runtime_dependency(%q<link_header>, ["~> 0.0.5"])
      s.add_development_dependency(%q<rspec>, ["~> 2.6.0"])
      s.add_development_dependency(%q<mocha>, ["~> 0.9.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.8.0"])
      s.add_development_dependency(%q<bluecloth>, ["~> 2.1.0"])
    else
      s.add_dependency(%q<httparty>, ["~> 0.7.8"])
      s.add_dependency(%q<link_header>, ["~> 0.0.5"])
      s.add_dependency(%q<rspec>, ["~> 2.6.0"])
      s.add_dependency(%q<mocha>, ["~> 0.9.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<yard>, ["~> 0.6.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.8.0"])
      s.add_dependency(%q<bluecloth>, ["~> 2.1.0"])
    end
  else
    s.add_dependency(%q<httparty>, ["~> 0.7.8"])
    s.add_dependency(%q<link_header>, ["~> 0.0.5"])
    s.add_dependency(%q<rspec>, ["~> 2.6.0"])
    s.add_dependency(%q<mocha>, ["~> 0.9.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<yard>, ["~> 0.6.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.8.0"])
    s.add_dependency(%q<bluecloth>, ["~> 2.1.0"])
  end
end

