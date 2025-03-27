module RspecWatchdogs
  class WatchdogController < ApplicationController
    skip_forgery_protection
    before_action :authenticate_token

    # CREATE
    def analytics
      Metric.create!(metric_params)
    end

    def flakiness
      Flaky.create!(flaky_params)
    end

    private

    def metric_params
      params.require(:metric).permit(:description, :file_path, :location, :run_time, :status, :error_message)
    end

    def flaky_params
      params.require(:flaky).permit(:description, :file_path, :location, :error, :run_time, :status, :error_message)
    end

    def authenticate_token
      expected_token = ENV['WATCHDOGS_API_TOKEN']
      request_token = request.headers["Authorization"]
      puts "Request token: #{request_token}"

      unless request_token.present? && ActiveSupport::SecurityUtils.secure_compare(request_token, expected_token)
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
  end
end
