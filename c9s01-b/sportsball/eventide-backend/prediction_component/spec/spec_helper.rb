require 'pp'

require_relative '../lib/prediction_component/client'
require_relative '../lib/prediction_component/implementation'

# ENV['CONSOLE_DEVICE'] ||= 'stdout'
# ENV['LOG_LEVEL'] ||= 'info'
# ENV['LOG_TAGS'] ||= '_untagged,-data,messaging,entity_projection,entity_store,ignored'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
end
