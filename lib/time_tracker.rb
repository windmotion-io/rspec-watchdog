require 'benchmark'
# require the environment file

module RspecWatchdogs
  class TimeTracker
    def initialize
      @test_times = {}
    end

    def track_time(example)
      total_time = Benchmark.measure do
        yield
      end

      @test_times[example.full_description] = {
        time: total_time.real,
        file_path: example.file_path,
        line_number: example.location
      }

      watchdog = RspecWatchdogs::Metric.find_or_initialize_by(description: example.full_description)
      if watchdog.persisted?
        watchdog.update!(run_time: total_time.real, file_path: example.file_path, location: example.location)
        puts "Registro actualizado: #{watchdog.inspect}"
        puts watchdog.class.table_name
      else
        watchdog.assign_attributes(run_time: total_time.real, file_path: example.file_path, location: example.location)
        watchdog.save!
        puts "Registro creado: #{watchdog.inspect}"
      end
    end

    def print_summary
      return if @test_times.empty?

      puts "\n\033[1;36m--- RSpec Watchdogs Test Time Summary ---\033[0m" # Cyan y negrita
      sorted_times = @test_times.sort_by { |_, data| -data[:time] }

      sorted_times.each do |description, data|
        color = data[:time] > 10 ? "\033[1;31m" : "\033[1;32m" # Rojo si es muy lento, verde si es rápido
        puts "#{color}#{description}\033[0m"
        puts "  ⏳ Time: \033[1;33m#{sprintf('%.4f', data[:time])} seconds\033[0m" # Amarillo
        puts "  📍 Location: \033[1;34m#{data[:file_path]}:#{data[:line_number]}\033[0m" # Azul
        puts ""
      end

      puts "✅ Total tests tracked: \033[1;32m#{@test_times.size}\033[0m" # Verde
      puts "🐌 Slowest test: \033[1;31m#{sorted_times.first[0]}\033[0m (\033[1;33m#{sprintf('%.4f', sorted_times.first[1][:time])} seconds\033[0m)" # Rojo y amarillo
    end
  end
end
