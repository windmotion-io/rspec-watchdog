require "rspec_watchdogs/version"
require "rspec_watchdogs/engine"
require_relative "time_tracker"

module RspecWatchdogs
  mattr_accessor :api_token
  self.api_token = ENV.fetch("WATCHDOGS_API_TOKEN", "default_token")

  def self.tracker
    @tracker ||= TimeTracker.new
  end

  def self.setup
    puts "SABE"
    # RSpec.configure do |config|
    #   config.around(:each) do |rspec_test|
    #     RspecWatchdogs.tracker.track_time(rspec_test) do
    #       rspec_test.run
    #     end
    #   end

    #   config.after(:suite) do
    #     RspecWatchdogs.tracker.print_summary
    #   end
    # end
  end
end


if defined?(RSpec) && defined?(RSpec::Core)
  puts "RSpec is defined"
  RspecWatchdogs.setup
else
  puts "RSpec is not defined"
end
