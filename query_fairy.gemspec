require_relative "lib/query_fairy/version"

Gem::Specification.new do |spec|
  spec.name        = "query_fairy"
  spec.version     = QueryFairy::VERSION
  spec.authors     = ["salzamt"]
  spec.email       = ["beschwerden@salzamt.xyz"]
  spec.homepage    = "https://salzamt.xyz"
  spec.summary     = "Summary of QueryFairy."
  spec.description = "Description of QueryFairy."
    spec.license     = "MIT"
  
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = 'http://mygemserver.com'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://github.com/salzamt/query-fairy'
  spec.metadata["changelog_uri"] = "https://github.com/salzamt/query-fairy/releases"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 6.1.4"
end
