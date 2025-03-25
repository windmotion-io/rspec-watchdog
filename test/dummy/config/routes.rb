Rails.application.routes.draw do
  mount RspecWatchdogs::Engine => "/rspec_watchdogs"
end
