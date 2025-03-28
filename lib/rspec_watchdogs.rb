require "rspec_watchdogs/version"

if defined?(Rails)
  require "rspec_watchdogs/engine"
  module RspecWatchdogs
  end
else
  module RspecWatchdogs
    class << self
      attr_accessor :config

      def configure
        self.config ||= Configuration.new
        yield(config) if block_given?
      end
    end

    class Configuration
      attr_accessor :show_logs, :watchdogs_api_url, :watchdogs_api_token
    end
  end

  require "rspec_watchdogs/slow_spec_formatter"
end
