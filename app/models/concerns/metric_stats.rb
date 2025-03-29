module MetricStats
  extend ActiveSupport::Concern

  def average_time
    RspecWatchdog::Metric.all.average(:run_time)
  end

  def fastest_test
    RspecWatchdog::Metric.order(:run_time).first
  end

  def slowest_test
    RspecWatchdog::Metric.order(run_time: :desc).first
  end

  def percentiles
    total = RspecWatchdog::Metric.count
    [0.25, 0.5, 0.75].map do |p|
      index = (total * p).round - 1
      example = RspecWatchdog::Metric.order(:run_time).limit(1).offset(index).first
      {
        percentile: (p * 100).to_i,
        description: example.description,
        file_path: example.file_path,
        run_time: example.run_time
      }
    end
  end

  def failed_tests
    RspecWatchdog::Metric.where(status: 'failed')
  end

  def tests_grouped_by_file
    RspecWatchdog::Metric.group(:file_path).order(:file_path)
  end

  def tests_that_took_longer_than(threshold)
    RspecWatchdog::Metric.where('run_time > ?', threshold)
  end

  def time_distribution_analysis
    total_tests = RspecWatchdog::Metric.count
    categories = {
      "⚡ Ultra Fast (< 0.01s)" => 0,
      "🚀 Fast (0.01s - 0.1s)" => 0,
      "🏃 Normal (0.1s - 0.5s)" => 0,
      "🚶 Slow (0.5s - 1s)" => 0,
      "🐢 Very Slow (> 1s)" => 0
    }

    RspecWatchdog::Metric.find_each do |ex|
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
    total_tests = RspecWatchdog::Metric.count
    passed = RspecWatchdog::Metric.where(status: 'passed').count
    failed = RspecWatchdog::Metric.where(status: 'failed').count
    pending = RspecWatchdog::Metric.where(status: 'pending').count

    {
      total_tests: total_tests,
      passed_percentage: (passed.to_f / total_tests * 100).round(2),
      failed_percentage: (failed.to_f / total_tests * 100).round(2),
      pending_percentage: (pending.to_f / total_tests * 100).round(2)
    }
  end

  def execution_time_variance
    run_times = RspecWatchdog::Metric.pluck(:run_time)
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
    sorted_by_complexity = RspecWatchdog::Metric.order(:run_time)

    sorted_by_complexity.first(3).map do |ex|
      {
        description: ex.description,
        file_path: ex.file_path,
        execution_time: ex.run_time
      }
    end
  end

  def test_dependency_analysis
    file_dependencies = RspecWatchdog::Metric.group(:file_path).having("count(*) > 1").count

    file_dependencies.map do |file, count|
      {
        file: file,
        number_of_tests: count,
        average_execution_time: RspecWatchdog::Metric.where(file_path: file).average(:run_time)
      }
    end
  end

  # HISTORIC DATA
  def run_time_distribution(bin_size = 1.0)
    RspecWatchdog::Metric.select("FLOOR(run_time / #{bin_size}) as run_time_bin,
                                    COUNT(*) as test_count")
                            .group("run_time_bin")
                            .order("run_time_bin")
  end

  def performance_trend(days = 30)
    RspecWatchdog::Metric
      .select("DATE(created_at) as test_date, AVG(run_time) as average_run_time")
      .where(created_at: days.days.ago..Time.current.end_of_day) # ← INCLUYE HOY COMPLETO
      .group("DATE(created_at)")
      .order("DATE(created_at)")
      .map { |m| { test_date: m.test_date.to_s, average_run_time: m.average_run_time.to_f } }
  end

  def test_count_trend(days = 30)
    RspecWatchdog::Metric
      .select("DATE(created_at) as test_date, COUNT(*) as test_count")
      .where(created_at: days.days.ago..Time.current.end_of_day)
      .group("DATE(created_at)")
      .order("DATE(created_at)")
      .map { |m| { test_date: m.test_date.to_s, test_count: m.test_count } }
  end

  def longest_tests_by_day(days = 30)
    RspecWatchdog::Metric
      .select("DATE(created_at) as test_date, description, run_time")
      .where(created_at: days.days.ago..Time.current.end_of_day)
      .where("run_time = (SELECT MAX(run_time) FROM rspec_watchdog_metrics AS m2 WHERE DATE(m2.created_at) = DATE(rspec_watchdog_metrics.created_at))")
      .order("test_date DESC") # Ordenamos por fecha
      .map { |m| { test_date: m.test_date.to_s, description: m.description, run_time: m.run_time.to_f } }
  end

  def total_execution_time_by_day(days = 30)
    RspecWatchdog::Metric
      .select("DATE(created_at) as test_date, SUM(run_time) as total_run_time")
      .where(created_at: days.days.ago..Time.current.end_of_day)
      .group("DATE(created_at)")
      .order("DATE(created_at)")
      .map { |m| { test_date: m.test_date.to_s, total_run_time: m.total_run_time } }
  end

  def tests_exceeding_time_threshold(threshold = 1.0, days = 30)
    RspecWatchdog::Metric
      .select("DATE(created_at) as test_date, COUNT(*) as test_count")
      .where('run_time > ?', threshold)
      .where(created_at: days.days.ago..Time.current.end_of_day)
      .group("DATE(created_at)")
      .order("DATE(created_at)")
      .map { |m| { test_date: m.test_date.to_s, test_count: m.test_count } }
  end

  def failed_tests_trend_by_file(days = 30)
    RspecWatchdog::Metric
      .select("DATE(created_at) as test_date, file_path, COUNT(*) as failed_count")
      .where(status: 'failed', created_at: days.days.ago..Time.current.end_of_day)
      .group("DATE(created_at), file_path")
      .order("DATE(created_at), failed_count DESC")
      .map { |m| { test_date: m.test_date.to_s, file_path: m.file_path, failed_count: m.failed_count } }
  end
def avg_execution_time_by_file(days = 30)
  RspecWatchdog::Metric
    .select("file_path, AVG(run_time) as average_run_time")
    .where(created_at: days.days.ago..Time.current.end_of_day)
    .where("run_time IS NOT NULL") # Filtrar nulos si es necesario
    .group("file_path")
    .order("average_run_time DESC")
    .map { |m| { file_path: m.file_path, average_run_time: m.average_run_time.to_f.round(2) } } # Asegurarse de que sea flotante
end


def stability_trend(days = 30)
  RspecWatchdog::Metric
    .select("DATE(created_at) as test_date,
             SUM(CASE WHEN status = 'passed' THEN 1 ELSE 0 END) as passed_count,
             SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed_count,
             SUM(CASE WHEN status = 'skipped' THEN 1 ELSE 0 END) as skipped_count,
             SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_count,
             SUM(CASE WHEN status = 'error' THEN 1 ELSE 0 END) as error_count")
    .where(created_at: days.days.ago..Time.current.end_of_day)
    .group("DATE(created_at)") # Asegúrate de que solo agrupas por la fecha, no por otros campos
    .order("DATE(created_at)")
    .map { |m|
      {
        test_date: m.test_date.to_s,
        passed_count: m.passed_count,
        failed_count: m.failed_count,
        skipped_count: m.skipped_count,
        pending_count: m.pending_count,
        error_count: m.error_count
      }
    }
end

end
