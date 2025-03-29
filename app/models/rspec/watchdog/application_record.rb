module Rspec::Watchdog
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
