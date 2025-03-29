module Rspec::Watchdog
  class Engine < ::Rails::Engine
    isolate_namespace RspecWatchdog
  end
end
