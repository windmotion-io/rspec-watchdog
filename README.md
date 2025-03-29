# RspecWatchdog

RspecWatchdog is a gem designed to track the performance and reliability of your RSpec tests. It provides useful metrics like execution times, test failures, and flaky tests, and presents them in a visual dashboard. With seamless integration into your existing RSpec setup, you can monitor test performance and diagnose flaky tests, improving both test suite efficiency and reliability.

## Motivation

Testing is a crucial part of the development process, but it can be challenging to track and maintain an efficient test suite. RspecWatchdog offers a simple way to monitor test performance, identify slow tests, and spot flaky tests—helping you improve test reliability and speed. By integrating with rspec-rebound, this gem gives you insights into tests that frequently fail, allowing you to address instability in your suite.

## Features

- Performance tracking: Measure the execution time of individual tests to identify slow or inefficient tests.

- Test statistics: View summary metrics, such as total runs, failures, and average test times.

- Flaky test detection: Integrated with rspec-rebound to help you spot flaky tests that fail intermittently.

- Dashboard integration: Visualize metrics and trends on an intuitive dashboard to track test suite health.

- Minimal dependencies: The gem only requires RSpec, making it easy to integrate into any project that uses RSpec for testing.

## Installation Guide

### Step 1: Install the Gem

Add rspec_watchdog to your Gemfile:

```
gem 'rspec-watchdog'
```

Then, run:

```
bundle install
```

### Step 2: Dashboard Setup (Optional)

1. If you're using Rails and want to take advantage of the visual dashboard to monitor your test metrics, follow these steps:

Install the necessary migrations:

```
rake rspec_watchdog:install:migrations
```

2. Run the database migrations:

```
rails db:migrate
```

3. Add the RspecWatchdog engine to your routes:

In your config/routes.rb, add the following line:

```
mount RspecWatchdog::Engine => "/watchdog"
```

This will make the dashboard available at /watchdog on your Rails app.

### Step 3: Configuration

Regardless of whether you're using Rails or just RSpec, you need to configure rspec_watchdog in your spec_helper.rb or rails_helper.rb.

**For Rails users:**
In spec/rails_helper.rb, add the following:

```
require "rspec_watchdog"

RspecWatchdog.configure do |config|
  config.show_logs = true
  config.watchdog_api_url = "http://localhost:3000/watchdog/analytics"
  config.watchdog_api_token = "AAA"
end

RSpec.configure do |config|
  config.add_formatter(:progress) # default rspec formatter
  config.add_formatter(SlowSpecFormatter)
end
```

**IMPORTANT:** You also need to create a configuration file in config/initializers/rspec_watchdog.rb with the following content:

```
RspecWatchdog.configure do |config|
  config.watchdog_api_token = "AAA"
end
```

**For RSpec-only users (without Rails):**
In your spec/spec_helper.rb, add the following:

```

require "rspec_watchdog"

RspecWatchdog.configure do |config|
  config.show_logs = true
  config.watchdog_api_url = "http://localhost:3000/watchdog/analytics"
  config.watchdog_api_token = "AAA"
end

RSpec.configure do |config|
  config.add_formatter(:progress)
  config.add_formatter(SlowSpecFormatter)
end

```

Make sure to replace "AAA" with your actual API token.

### Configuration Options Explained

#### `watchdog_api_url`

This is the endpoint where test execution data will be sent after each RSpec test finishes.

- By default, if you use the provided URL (`http://localhost:3000/watchdog/analytics`) and have mounted the engine routes, the data will be stored on your own server.
- This allows you to track and visualize test performance and failures over time.

#### `watchdog_api_token`

This token is used to validate that the request being sent to the API is legitimate.

- If you're running tests in a CI/CD environment (e.g., GitHub Actions or CircleCI) and sending data to your own server, you can compare the `Authorization` header in the request with an environment variable on your server.
- If they match, the request is considered valid, and the test metrics are stored.

#### `show_logs`

When set to `true`, this option enables additional logging for RSpec tests.

- These logs provide insights into test execution, including test runtimes and other relevant debugging information.
- This can be useful for diagnosing slow tests or identifying issues during test runs.

By configuring these options, you can gain better visibility into your RSpec tests and integrate test analytics into your workflow.

### Step 4: Running Your Tests

Once everything is set up, you can run your tests as usual with RSpec. Metrics and flaky test information will be collected and displayed according to your configuration.

# Usage

After installation, RspecWatchdog automatically hooks into your RSpec test suite. You can start tracking your tests immediately without any additional configuration.

To view the test metrics and flaky test reports, simply run your RSpec tests as usual, and the gem will capture and display the results in the dashboard.

You can also configure additional settings for customizing the metrics you want to track.

# Integration with RSpec-Rebound

RspecWatchdog integrates with rspec-rebound to track flaky tests. By enabling both gems in your project, you can easily spot tests that fail inconsistently, making it easier to identify root causes and improve the stability of your test suite.

# Contributing

We welcome contributions to rspec_watchdog! If you have ideas, suggestions, or find a bug, please open an issue or submit a pull request on GitHub.

# License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

```

```
