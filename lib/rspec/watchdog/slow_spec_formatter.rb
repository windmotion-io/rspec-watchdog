require 'rspec/core/formatters/base_text_formatter'
require 'net/http'
require 'json'

class SlowSpecFormatter
  RSpec::Core::Formatters.register self, :dump_summary

  def initialize(output)
    @output = output
    @show_logs = Rspec::Watchdog.config.show_logs
    @flaky_spec_detection = RSpec.configuration.flaky_spec_detection
    @watchdog_api_url = Rspec::Watchdog.config.watchdog_api_url
    @watchdog_api_token = Rspec::Watchdog.config.watchdog_api_token
    @fast_specs_threshold = RSpec.configuration.fast_specs_threshold
  end

  def dump_summary(summary)
    if @show_logs
      puts "\nAll examples sorted by run time (most durable to fastest):"
    end

    all_examples = summary.examples.map do |example|
      {
        description: example.full_description,
        file_path: example.metadata[:file_path],
        location: example.metadata[:location],
        run_time: example.execution_result.run_time,
        status: example.execution_result.status.to_s,
        error_message: example.execution_result.exception ? example.execution_result.exception.message : nil,
        flaky: example.metadata[:flaky] || false
      }
    end

    if @fast_specs_threshold
      all_examples = all_examples.select { |ex| ex[:run_time] > @fast_specs_threshold && !ex[:flaky] }
    end

    sorted_examples = all_examples.sort_by { |ex| -ex[:run_time] }

    sorted_examples.each do |ex|
      puts "#{ex[:description]} (#{ex[:file_path]}) - #{ex[:run_time]} seconds - #{ex[:location]}"
    end

    if @show_logs
      calculate_average_time(summary)
      fastest_test(sorted_examples)
      slowest_test(sorted_examples)
      percentiles(sorted_examples)
      failed_tests(summary)
      tests_grouped_by_file(sorted_examples)
      tests_that_tooked_longer_than(sorted_examples, 2.0)
      time_distribution_analysis(sorted_examples)
      test_stability_analysis(summary)
      execution_time_variance(sorted_examples)
      temporal_complexity_analysis(sorted_examples)
      test_dependency_analysis(sorted_examples)
    end

    return unless @watchdog_api_url && @watchdog_api_token

    send_to_api(sorted_examples)
  end

  private

  def calculate_average_time(summary)
    average_time = summary.duration / summary.example_count
    puts "\n🕒 \e[34mAverage time per example:\e[0m #{format('%.4f', average_time)} seconds"
  end

  def fastest_test(sorted_examples)
    fastest = sorted_examples.last
    puts "\n🚀 \e[32mFastest test:\e[0m #{fastest[:description]} (#{fastest[:file_path]}) - #{format('%.4f',
                                                                                                     fastest[:run_time])} seconds"
  end

  def slowest_test(sorted_examples)
    slowest = sorted_examples.first
    puts "\n🐢 \e[31mSlowest test:\e[0m #{slowest[:description]} (#{slowest[:file_path]}) - #{format('%.4f',
                                                                                                     slowest[:run_time])} seconds"
  end

  def percentiles(sorted_examples)
    percentiles = [0.25, 0.5, 0.75].map do |p|
      index = (sorted_examples.size * p).round - 1
      example = sorted_examples[index]
      {
        percentile: (p * 100).to_i,
        description: example[:description],
        file_path: example[:file_path],
        run_time: example[:run_time]
      }
    end
    percentiles.each do |p|
      puts "\n📊 \e[35m#{p[:percentile]}th percentile:\e[0m #{p[:description]} (#{p[:file_path]}) - #{format('%.4f',
                                                                                                             p[:run_time])} seconds"
    end
  end

  def failed_tests(summary)
    failed = summary.examples.select { |example| example.execution_result.status == :failed }
    puts "\n❌ \e[31mFailed tests:\e[0m"
    failed.each do |example|
      puts "\e[31m#{example.full_description} (#{example.metadata[:file_path]}) - #{example.execution_result.run_time} seconds\e[0m"
      puts "  \e[33mLocation:\e[0m #{example.metadata[:location]}"
      puts "  \e[31mFailure message:\e[0m #{example.execution_result.exception.message}"
    end
  end

  def tests_grouped_by_file(sorted_examples)
    grouped_by_file = sorted_examples.group_by { |ex| ex[:file_path] }
    puts "\n📁 \e[36mTests grouped by file:\e[0m"
    grouped_by_file.each do |file_path, examples|
      puts "\n\e[36mFile:\e[0m #{file_path}"
      examples.each do |ex|
        puts "  🧪 #{ex[:description]} - #{format('%.4f', ex[:run_time])} seconds"
        puts "  📍 Location: #{ex[:location]}"
        puts '  '
      end
    end
  end

  def tests_that_tooked_longer_than(sorted_examples, threshold)
    long_tests = sorted_examples.select { |ex| ex[:run_time] > threshold }
    puts "\n⏳ \e[33mTests that took longer than #{threshold} seconds:\e[0m"
    long_tests.each do |ex|
      puts "\e[33m#{ex[:description]} (#{ex[:file_path]}) - #{format('%.4f', ex[:run_time])} seconds\e[0m"
      puts "  📍 Location: #{ex[:location]}"
    end
  end

  def time_distribution_analysis(sorted_examples)
    total_tests = sorted_examples.size

    categories = {
      '⚡ Ultra Fast (< 0.01s)' => 0,
      '🚀 Fast (0.01s - 0.1s)' => 0,
      '🏃 Normal (0.1s - 0.5s)' => 0,
      '🚶 Slow (0.5s - 1s)' => 0,
      '🐢 Very Slow (> 1s)' => 0
    }

    sorted_examples.each do |ex|
      case ex[:run_time]
      when 0...0.01
        categories['⚡ Ultra Fast (< 0.01s)'] += 1
      when 0.01...0.1
        categories['🚀 Fast (0.01s - 0.1s)'] += 1
      when 0.1...0.5
        categories['🏃 Normal (0.1s - 0.5s)'] += 1
      when 0.5...1.0
        categories['🚶 Slow (0.5s - 1s)'] += 1
      else
        categories['🐢 Very Slow (> 1s)'] += 1
      end
    end

    puts "\n📊 \e[36mTime Distribution Analysis:\e[0m"
    categories.each do |category, count|
      percentage = (count.to_f / total_tests * 100).round(2)
      puts "#{category}: #{count} tests (#{percentage}%)"
    end
  end

  def test_stability_analysis(summary)
    total_tests = summary.example_count
    passed = summary.examples.select { |e| e.execution_result.status == :passed }.count
    failed = summary.examples.select { |e| e.execution_result.status == :failed }.count
    pending = summary.examples.select { |e| e.execution_result.status == :pending }.count

    puts "\n🛡️ \e[34mTest Suite Stability:\e[0m"
    puts "Total Tests: #{total_tests}"
    puts "\e[32m✅ Passed: #{passed} (#{(passed.to_f / total_tests * 100).round(2)}%)\e[0m"
    puts "\e[31m❌ Failed: #{failed} (#{(failed.to_f / total_tests * 100).round(2)}%)\e[0m"
    puts "\e[33m⏳ Pending: #{pending} (#{(pending.to_f / total_tests * 100).round(2)}%)\e[0m"
  end

  def execution_time_variance(sorted_examples)
    run_times = sorted_examples.map { |ex| ex[:run_time] }
    mean = run_times.sum / run_times.size
    variance = run_times.map { |time| (time - mean)**2 }.sum / run_times.size
    std_dev = Math.sqrt(variance)

    puts "\n📈 \e[35mExecution Time Variance:\e[0m"
    puts "Mean Execution Time: #{format('%.4f', mean)} seconds"
    puts "Variance: #{format('%.4f', variance)} seconds²"
    puts "Standard Deviation: #{format('%.4f', std_dev)} seconds"
  end

  def temporal_complexity_analysis(sorted_examples)
    sorted_by_complexity = sorted_examples.sort_by { |ex| ex[:run_time] }

    puts "\n🧩 \e[32mTemporal Complexity Analysis:\e[0m"
    puts 'Top 3 Most Complex Tests:'
    sorted_by_complexity.first(3).each_with_index do |ex, index|
      puts "#{index + 1}. #{ex[:description]}"
      puts "   File: #{ex[:file_path]}"
      puts "   Execution Time: #{format('%.4f', ex[:run_time])} seconds"
    end
  end

  def test_dependency_analysis(sorted_examples)
    file_dependencies = sorted_examples.group_by { |ex| ex[:file_path] }

    puts "\n🔗 \e[33mTest Dependency Analysis:\e[0m"
    file_dependencies.each do |file, tests|
      next if tests.size < 2

      puts "Potential Dependency Group: #{file}"
      puts "Number of Tests: #{tests.size}"
      puts "Average Execution Time: #{format('%.4f', tests.map { |t| t[:run_time] }.sum / tests.size)} seconds"
    end
  end

  def send_to_api(sorted_examples)
    uri = URI.parse(@watchdog_api_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    batch_size = 30
    sorted_examples.each_slice(batch_size) do |batch|
      puts "🌐 Sending batch of #{batch.size} to Analytics API"
      timestamp = Time.now.to_i
      batch_payload = batch.map do |example|
        {
          description: example[:description],
          file_path: example[:file_path],
          location: example[:location],
          run_time: example[:run_time],
          status: example[:status],
          error_message: example[:error_message],
          timestamp: timestamp,
          flaky: example[:flaky]
        }.merge(@flaky_spec_detection ? { flaky: example[:flaky] } : {})
      end

      request = Net::HTTP::Post.new(uri.path, {
                                      'Content-Type' => 'application/json',
                                      'Authorization' => @watchdog_api_token
                                    })
      request.body = { metrics: batch_payload }.to_json

      begin
        response = http.request(request)
        puts "✅ Batch sent successfully: #{response.code} #{response.message}"
      rescue StandardError => e
        puts "❌ Error sending batch: #{e.message}"
      end
    end
  end
end
