require "rspec_watchdog/version"

module RspecWatchdog
  class << self
    attr_accessor :config

    def configure
      self.config ||= Configuration.new
      yield(config) if block_given?
    end
  end

  class Configuration
    attr_accessor :show_logs, :watchdog_api_url, :watchdog_api_token
  end
end

if defined?(Rails)
  require "rspec_watchdog/engine"
else
  require "rspec_watchdog/slow_spec_formatter"
end
