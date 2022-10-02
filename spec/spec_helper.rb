# frozen_string_literal: true

require "simplecov"
SimpleCov.start

ENV["APP_ENV"] = "test"

require "active_support/testing/time_helpers"
require "dry/monads/result"
require_relative "../config/application"
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner[:active_record]
    DatabaseCleaner.strategy = :truncation
  end

  config.before do
    DatabaseCleaner[:active_record]
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:active_record].start

    stub_request(:get, /api.chucknorris.io/).to_return(status: 200, body: { value: "stubbed response" }.to_json, headers: {})
  end

  config.after do
    DatabaseCleaner[:active_record].clean
  end
end
