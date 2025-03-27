RspecWatchdogs::Engine.routes.draw do
  get "dashboard/index"
  get "metrics", to: "dashboard#metrics"

  root to: "dashboard#index"

  post "/analytics", to: "watchdog#analytics"
  post "/flakiness", to: "watchdog#flakiness"
end
