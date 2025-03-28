module RspecWatchdogs
  class DashboardController < ApplicationController
    include MetricStats

    def index
    end

    def historic
      @metrics = Metric.all

      @run_time_distribution = run_time_distribution
      @performance_trend = performance_trend
      @test_count_trend = test_count_trend
      @longest_tests_by_day = longest_tests_by_day
      @total_execution_time_by_day = total_execution_time_by_day
      @tests_exceeding_time_threshold = tests_exceeding_time_threshold
      @failed_tests_trend_by_file = failed_tests_trend_by_file
      @avg_execution_time_by_file = avg_execution_time_by_file
      @stability_trend = stability_trend
    end

    def metrics
      return redirect_to root_path if Metric.count.zero?

      @metrics = Metric.all
      @average_time = average_time
      @fastest_test = fastest_test
      @slowest_test = slowest_test
      @percentiles = percentiles
      @failed_tests = failed_tests
      @tests_grouped_by_file = tests_grouped_by_file
      @tests_that_took_longer_than = tests_that_took_longer_than(0.5)  # Puedes ajustar el umbral
      @time_distribution_analysis = time_distribution_analysis

      @test_stability_analysis = test_stability_analysis
      @total_tests = @test_stability_analysis[:total_tests]
      @passed_percentage = @test_stability_analysis[:passed_percentage]
      @failed_percentage = @test_stability_analysis[:failed_percentage]
      @pending_percentage = @test_stability_analysis[:pending_percentage]

      @execution_time_variance = execution_time_variance
      @temporal_complexity_analysis = temporal_complexity_analysis
      @test_dependency_analysis = test_dependency_analysis
    end
  end
end
