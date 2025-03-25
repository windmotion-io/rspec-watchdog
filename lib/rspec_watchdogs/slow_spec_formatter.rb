require "rspec/core/formatters/base_text_formatter"

class SlowSpecFormatter
  RSpec::Core::Formatters.register self, :dump_summary

  def initialize(output)
    @output = output
  end

  # # Called each time an example finishes
  # def example_finished(notification)
  #   puts "example_finished: #{notification.example.full_description}"
  #   example = notification.example
  #   if example.execution_result.run_time > threshold_time
  #     @@slow_examples << {
  #       description: example.full_description,
  #       file_path: example.metadata[:file_path],
  #       run_time: example.execution_result.run_time
  #     }
  #   end
  # end

  def dump_summary(summary)
    puts "\nAll examples sorted by run time (most durable to fastest):"

    # Crear una lista con todos los ejemplos y sus tiempos de ejecución
    all_examples = summary.examples.map do |example|
      {
        description: example.full_description,
        file_path: example.metadata[:file_path],
        location: example.metadata[:location],
        run_time: example.execution_result.run_time
      }
    end
    # Ordenar los ejemplos por tiempo de ejecución (de más duraderos a más rápidos)
    sorted_examples = all_examples.sort_by { |ex| -ex[:run_time] }

    # Imprimir los ejemplos ordenados
    sorted_examples.each do |ex|
      puts "#{ex[:description]} (#{ex[:file_path]}) - #{ex[:run_time]} seconds - #{ex[:location]}"
    end

    calculate_average_time(summary)
    fastest_test(sorted_examples)
    slowest_test(sorted_examples)
    percentiles(sorted_examples)
    failed_tests(summary)
    tests_grouped_by_file(sorted_examples)
    tests_that_tooked_longer_than(sorted_examples, 2.0)
    number_of_retries(summary)
    time_distribution_analysis(sorted_examples)
    test_stability_analysis(summary)
    execution_time_variance(sorted_examples)
    temporal_complexity_analysis(sorted_examples)
    test_dependency_analysis(sorted_examples)

    # Optionally, send data to an external API:
    send_to_api(sorted_examples)
  end

  private

  def calculate_average_time(summary)
    average_time = summary.duration / summary.example_count
    puts "\n🕒 \e[34mAverage time per example:\e[0m #{sprintf('%.4f', average_time)} seconds"
  end

  def fastest_test(sorted_examples)
    fastest = sorted_examples.last
    puts "\n🚀 \e[32mFastest test:\e[0m #{fastest[:description]} (#{fastest[:file_path]}) - #{sprintf('%.4f', fastest[:run_time])} seconds"
  end

  def slowest_test(sorted_examples)
    slowest = sorted_examples.first
    puts "\n🐢 \e[31mSlowest test:\e[0m #{slowest[:description]} (#{slowest[:file_path]}) - #{sprintf('%.4f', slowest[:run_time])} seconds"
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
      puts "\n📊 \e[35m#{p[:percentile]}th percentile:\e[0m #{p[:description]} (#{p[:file_path]}) - #{sprintf('%.4f', p[:run_time])} seconds"
    end
  end

  def failed_tests(summary)
    failed = summary.examples.select { |example| example.execution_result.status == :failed }
    puts "\n❌ \e[31mFailed tests:\e[0m"
    failed.each do |example|
      puts "\e[31m#{example.full_description} (#{example.metadata[:file_path]}) - #{example.execution_result.run_time} seconds\e[0m"
      puts "  \e[33mLocation:\e[0m #{example.metadata[:location]}"
      puts "  \e[31mFailure message:\e[0m #{example.execution_result.exception.message}"
      # puts "  \e[35mBacktrace:\e[0m #{example.execution_result.exception.backtrace.join("\n")}"
    end
  end

  def tests_grouped_by_file(sorted_examples)
    grouped_by_file = sorted_examples.group_by { |ex| ex[:file_path] }
    puts "\n📁 \e[36mTests grouped by file:\e[0m"
    grouped_by_file.each do |file_path, examples|
      puts "\n\e[36mFile:\e[0m #{file_path}"
      examples.each do |ex|
        puts "  🧪 #{ex[:description]} - #{sprintf('%.4f', ex[:run_time])} seconds"
        puts "  📍 Location: #{ex[:location]}"
        puts "  "
      end
    end
  end

  def tests_that_tooked_longer_than(sorted_examples, threshold)
    long_tests = sorted_examples.select { |ex| ex[:run_time] > threshold }
    puts "\n⏳ \e[33mTests that took longer than #{threshold} seconds:\e[0m"
    long_tests.each do |ex|
      puts "\e[33m#{ex[:description]} (#{ex[:file_path]}) - #{sprintf('%.4f', ex[:run_time])} seconds\e[0m"
      puts "  📍 Location: #{ex[:location]}"
    end
  end

  def number_of_retries(summary)
    retries = summary.examples.select { |example| example.execution_result.status == :retried }
    puts "\n🔁 \e[35mNumber of retries:\e[0m"
    retries.each do |example|
      puts "\e[35m#{example.full_description} (#{example.metadata[:file_path]}) - #{example.execution_result.run_time} seconds\e[0m"
      puts "  📍 Location: #{example.metadata[:location]}"
      puts "  \e[36mRetry count:\e[0m #{example.execution_result.retry_count}"
      puts "  \e[31mFailure message:\e[0m #{example.execution_result.exception.message}"
      puts "  \e[35mBacktrace:\e[0m #{example.execution_result.exception.backtrace.join("\n")}"
    end
  end

  def time_distribution_analysis(sorted_examples)
    total_tests = sorted_examples.size

    # Execution time categories
    categories = {
      "⚡ Ultra Fast (< 0.01s)" => 0,
      "🚀 Fast (0.01s - 0.1s)" => 0,
      "🏃 Normal (0.1s - 0.5s)" => 0,
      "🚶 Slow (0.5s - 1s)" => 0,
      "🐢 Very Slow (> 1s)" => 0
    }

    sorted_examples.each do |ex|
      case ex[:run_time]
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
    puts "\e[32m✅ Passed: #{passed} (#{(passed.to_f/total_tests*100).round(2)}%)\e[0m"
    puts "\e[31m❌ Failed: #{failed} (#{(failed.to_f/total_tests*100).round(2)}%)\e[0m"
    puts "\e[33m⏳ Pending: #{pending} (#{(pending.to_f/total_tests*100).round(2)}%)\e[0m"
  end

  def execution_time_variance(sorted_examples)
    run_times = sorted_examples.map { |ex| ex[:run_time] }

    # Calcular media
    mean = run_times.sum / run_times.size

    # Calcular varianza
    variance = run_times.map { |time| (time - mean) ** 2 }.sum / run_times.size

    # Calcular desviación estándar
    std_dev = Math.sqrt(variance)

    puts "\n📈 \e[35mExecution Time Variance:\e[0m"
    puts "Mean Execution Time: #{sprintf('%.4f', mean)} seconds"
    puts "Variance: #{sprintf('%.4f', variance)} seconds²"
    puts "Standard Deviation: #{sprintf('%.4f', std_dev)} seconds"
  end

  def temporal_complexity_analysis(sorted_examples)
    # Asume que el tiempo de ejecución podría estar relacionado con la complejidad del test
    sorted_by_complexity = sorted_examples.sort_by { |ex| ex[:run_time] }

    puts "\n🧩 \e[32mTemporal Complexity Analysis:\e[0m"
    puts "Top 3 Most Complex Tests:"
    sorted_by_complexity.first(3).each_with_index do |ex, index|
      puts "#{index + 1}. #{ex[:description]}"
      puts "   File: #{ex[:file_path]}"
      puts "   Execution Time: #{sprintf('%.4f', ex[:run_time])} seconds"
    end
  end

  def test_dependency_analysis(sorted_examples)
    # Analiza posibles agrupamientos o dependencias por ubicación de archivo
    file_dependencies = sorted_examples.group_by { |ex| ex[:file_path] }

    puts "\n🔗 \e[33mTest Dependency Analysis:\e[0m"
    file_dependencies.each do |file, tests|
      next if tests.size < 2

      puts "Potential Dependency Group: #{file}"
      puts "Number of Tests: #{tests.size}"
      puts "Average Execution Time: #{sprintf('%.4f', tests.map { |t| t[:run_time] }.sum / tests.size)} seconds"
    end
  end

  def threshold_time
    0.1  # Example threshold: specs running longer than 0.5 seconds are considered slow
  end

  require 'net/http'
  require 'json'
  require 'dotenv/load'

  def send_to_api(sorted_examples)

    uri = URI.parse("http://localhost:3000/watchdogs/analytics")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")

    first_example = sorted_examples.first
    puts "🌐 Sending data to Analytics API: #{uri}"
    request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json', 'Authorization' => ENV['WATCHDOGS_API_TOKEN'] })
    request.body = {
      metric: {
        description: first_example[:description],
        file_path: first_example[:file_path],
        location: first_example[:location],
        run_time: first_example[:run_time]
      }
    }.to_json

    begin
      response = http.request(request)
    rescue StandardError => e
      puts "Error sending data to API: #{e.message}"
    end
  end
end
