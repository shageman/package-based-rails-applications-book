ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "shoulda/matchers"

Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  config.include ObjectCreationMethods
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

def wait_for_turbolinks timeout = nil
  if has_css?('.turbolinks-progress-bar', visible: true, wait: (0.25).seconds)
    has_no_css?('.turbolinks-progress-bar', wait: timeout.presence || 5.seconds)
  end
end




require 'capybara/rspec'
require 'selenium/webdriver'

Capybara.default_driver = :rack_test # for non-JS tests
Capybara.javascript_driver = :headless_chrome

# Register a new driver for headless Chrome
Capybara.register_driver :headless_chrome do |app|
  options = ::Selenium::WebDriver::Chrome::Options.new
  # The list of arguments below are commonly used in CI
  %w[ headless disable-gpu no-sandbox disable-dev-shm-usage window-size=1280,800 ].each do |arg|
    options.add_argument(arg)
  end

  # If you are running your specs in Docker, you might also want:
  # options.add_argument('--remote-debugging-port=9222')
  # (helpful for debugging in certain setups)

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end