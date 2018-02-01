# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-embed}
  s.version = "0.0.2.pre"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Mendler"]
  s.date = %q{2009-03-04}
  s.email = ["mail@daniel-mendler.de"]
  s.extra_rdoc_files = ["README.md", "LICENSE"]
  s.files = %w(LICENSE Rakefile test/test_rack_embed.rb test/test.image rack-embed.gemspec Manifest.txt lib/rack/embed.rb README.md)
  s.has_rdoc = true
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rack-embed}
  s.rubygems_version = %q{1.3.1}
  s.homepage = %q{http://github.com/minad/rack-embed}

  s.summary = 'Rack::Embed embeds small images via the data-url (base64) if the browser supports it.'
  s.test_files = ["test/test_rack_embed.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 1.8.3"])
    else
      s.add_dependency(%q<hoe>, [">= 1.8.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 1.8.3"])
  end
end

