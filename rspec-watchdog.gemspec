require_relative "lib/rspec/watchdog/version"

Gem::Specification.new do |spec|
  spec.name        = "rspec-watchdog"
  spec.version     = Rspec::Watchdog::VERSION
  spec.authors       = ["Federico Aldunate", "Agustin Fornio"]
  spec.email         = ["tech@windmotion.io"]
  spec.summary       = "RSpec performance tracking and metrics"
  spec.description   = "Track RSpec test performance, identify slow tests, and generate metrics"
  spec.homepage      = "https://github.com/windmotion-io/rspec-watchdog"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://github.com/windmotion-io/rspec-watchdog"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/windmotion-io/rspec-watchdog"
  spec.metadata["changelog_uri"] = "https://github.com/windmotion-io/rspec-watchdog"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  # spec.add_dependency "rails", ">= 7.2.2.1" - REMOVE DEPENDENCY
  # spec.add_dependency "dotenv" - REMOVE DEPENDENCY
  spec.add_development_dependency "rspec", "~> 3.12"
end
