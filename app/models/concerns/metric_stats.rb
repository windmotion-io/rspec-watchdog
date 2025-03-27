module MetricStats
  extend ActiveSupport::Concern

  def average_time
    RspecWatchdogs::Metric.all.average(:run_time)
  end

  def fastest_test
    RspecWatchdogs::Metric.order(:run_time).first
  end

  def slowest_test
    RspecWatchdogs::Metric.order(run_time: :desc).first
  end

  def percentiles
    total = RspecWatchdogs::Metric.count
    [0.25, 0.5, 0.75].map do |p|
      index = (total * p).round - 1
      example = RspecWatchdogs::Metric.order(:run_time).limit(1).offset(index).first
      {
        percentile: (p * 100).to_i,
        description: example.description,
        file_path: example.file_path,
        run_time: example.run_time
      }
    end
  end

  def failed_tests
    RspecWatchdogs::Metric.where(status: 'failed')
  end

  def tests_grouped_by_file
    RspecWatchdogs::Metric.group(:file_path).order(:file_path)
  end

  def tests_that_took_longer_than(threshold)
    RspecWatchdogs::Metric.where('run_time > ?', threshold)
  end

  def time_distribution_analysis
    total_tests = RspecWatchdogs::Metric.count
    categories = {
      "⚡ Ultra Fast (< 0.01s)" => 0,
      "🚀 Fast (0.01s - 0.1s)" => 0,
      "🏃 Normal (0.1s - 0.5s)" => 0,
      "🚶 Slow (0.5s - 1s)" => 0,
      "🐢 Very Slow (> 1s)" => 0
    }

    RspecWatchdogs::Metric.find_each do |ex|
      case ex.run_time
      when 0...0.01
        categories["⚡ Ultra Fast (< 0.01s)"] += 1
      when 0.01...0.1
        categories["🚀 Fast (0.01s - 0.1s)"] += 1
      when 0.1...0.5
        categories["🏃 Normal (0.1s - 0.5s)"] += 1
      when 0.5...1.0
        categories["🚶 Slow (0.5s - 1s)"] += 1
      else
        categories["🐢 Very Slow (> 1s)"] += 1
      end
    end

    categories
  end

  def test_stability_analysis
    total_tests = RspecWatchdogs::Metric.count
    passed = RspecWatchdogs::Metric.where(status: 'passed').count
    failed = RspecWatchdogs::Metric.where(status: 'failed').count
    pending = RspecWatchdogs::Metric.where(status: 'pending').count

    {
      total_tests: total_tests,
      passed_percentage: (passed.to_f / total_tests * 100).round(2),
      failed_percentage: (failed.to_f / total_tests * 100).round(2),
      pending_percentage: (pending.to_f / total_tests * 100).round(2)
    }
  end

  def execution_time_variance
    run_times = RspecWatchdogs::Metric.pluck(:run_time)
    mean = run_times.sum / run_times.size
    variance = run_times.map { |time| (time - mean) ** 2 }.sum / run_times.size
    std_dev = Math.sqrt(variance)

    {
      mean: mean,
      variance: variance,
      standard_deviation: std_dev
    }
  end

  def temporal_complexity_analysis
    sorted_by_complexity = RspecWatchdogs::Metric.order(:run_time)

    sorted_by_complexity.first(3).map do |ex|
      {
        description: ex.description,
        file_path: ex.file_path,
        execution_time: ex.run_time
      }
    end
  end

  def test_dependency_analysis
    file_dependencies = RspecWatchdogs::Metric.group(:file_path).having("count(*) > 1").count

    file_dependencies.map do |file, count|
      {
        file: file,
        number_of_tests: count,
        average_execution_time: RspecWatchdogs::Metric.where(file_path: file).average(:run_time)
      }
    end
  end
end
