# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require_relative '../config/environment'
require 'active_support/testing/time_helpers'
require 'simplecov'
require 'webmock/rspec'

SimpleCov.start

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.configure do |config|
  WebMock.disable_net_connect!

  config.include ActiveSupport::Testing::TimeHelpers
  config.include Rack::Test::Methods
  config.include FactoryBot::Syntax::Methods

  def app = Root

  config.before do
    stub_const('EmojiAppender::EMOJIS', ['😀'])
  end

  config.include_context 'with default telegram setup', default_telegram_setup: true
  config.include_context 'with default twitch setup', default_twitch_setup: true
  %i[request job service].each do |type|
    config.include_context('with stubbed telegram bot client', type:)
    config.include_context('with stubbed twitch api client', type:)
  end

  config.before(:suite) do
    FactoryBot.find_definitions
  end

  config.color = true
  config.formatter = :documentation

  config.mock_with :rspec
  config.expect_with :rspec
  config.raise_errors_for_deprecations!

  config.before do
    mock_redis = MockRedis.new
    allow(Redis).to receive(:new).and_return(mock_redis)
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before do
    Kredis.redis.flushall
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.around(:each, type: :request) do |ex|
    Sidekiq::Testing.inline! { ex.run }
  end

  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.profile_examples = 5
  config.order = :random
  Kernel.srand config.seed
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :active_record
    with.library :active_model
  end
end

RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = nil
