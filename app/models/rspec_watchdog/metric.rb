module RspecWatchdog
  class Metric < ApplicationRecord
    # enum status: {
    #   passed: "passed",
    #   failed: "failed",
    #   skipped: "skipped",
    #   pending: "pending",
    #   error: "error"
    # }
  end
end
