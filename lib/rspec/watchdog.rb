require_relative "watchdog/version"
require "rspec/core" # Ensure RSpec is loaded first
require_relative "watchdog/slow_spec_formatter"

module Rspec
  module Watchdog
    class Error < StandardError; end

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
end
