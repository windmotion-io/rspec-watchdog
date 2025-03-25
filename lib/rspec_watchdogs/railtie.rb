module RspecWatchdogs
  class Railtie < ::Rails::Railtie
    # initializer 'rspec_watchdogs.check_metric_count' do |app|
    #   Rails.application.config.after_initialize do
    #     if defined?(RspecWatchdogs::Metric)
    #       puts "Metric count: #{RspecWatchdogs::Metric.count}"
    #     else
    #       puts "Metric model not found."
    #     end
    #   end
    # end
  end
end
