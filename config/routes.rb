RspecWatchdogs::Engine.routes.draw do
  get "dashboard/index"

  root to: "dashboard#index"
  post "/analytics", to: "watchdog#analytics"
  post "/flakiness", to: "watchdog#flakiness"
end
