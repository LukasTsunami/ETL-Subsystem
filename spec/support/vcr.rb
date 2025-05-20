# frozen_string_literal: true

require 'vcr'
require 'webmock/rspec'

VCR.configure do |config|
  # Directory where cassette files will be stored
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'

  # Use WebMock as the HTTP request interception library
  config.hook_into :webmock

  # Enable integration with RSpec (e.g., :vcr tag)
  config.configure_rspec_metadata!

  # Raise errors if real HTTP requests are made without a cassette
  config.allow_http_connections_when_no_cassette = false

  # Ignore local requests (e.g., capybara, etc.)
  config.ignore_localhost = true
  config.ignore_hosts '127.0.0.1', 'localhost'

  # Default behavior for all cassettes
  config.default_cassette_options = default_cassette_options

  # Filter out sensitive data from requests/responses
  configure_sensitive_data_filters(config)

  # Add custom matcher to avoid noise from irrelevant headers
  register_custom_header_matcher(config)

  # Sanitize response/request before persisting to cassette
  config.before_record do |interaction|
    sanitize_interaction(interaction)
  end
  # Enable debug logging to understand why a request didn’t match
  # (can be disabled in CI)
  config.debug_logger = $stdout if ENV['VCR_DEBUG'] == 'true'
end

# ======================
# Helpers and Matchers
# ======================

def default_cassette_options
  {
    match_requests_on: %i[method uri body custom_headers],
    record: :once,
    decode_compressed_response: true
  }
end

# :reek:DuplicateMethodCall
# :reek:FeatureEnvy
# :reek:TooManyStatements
# rubocop:disable Metrics/AbcSize
def configure_sensitive_data_filters(config)
  config.filter_sensitive_data('<token>') do |interaction|
    interaction.request.headers['Authorization']&.first
  end

  config.filter_sensitive_data('<client_id>') do |interaction|
    parse_nested_query(interaction.request.body)['client_id']
  rescue StandardError
    nil
  end

  config.filter_sensitive_data('<client_secret>') do |interaction|
    parse_nested_query(interaction.request.body)['client_secret']
  rescue StandardError
    nil
  end

  config.filter_sensitive_data('<access_token>') do |interaction|
    parse_json(interaction.response.body)['access_token']
  end
end

# :reek:UtilityFunction
# :reek:NestedIterators
# :reek:TooManyStatements
# :reek:DuplicateMethodCall
def register_custom_header_matcher(config)
  config.register_request_matcher :custom_headers do |incoming_request, recorded_request|
    headers_to_ignore = %w[
      User-Agent
      X-Request-Id
      X-Amzn-Trace-Id
      X-Correlation-Id
      X-Real-Ip
      X-Forwarded-For
    ]

    incoming_headers_filtered = incoming_request.headers.except(*headers_to_ignore)

    recorded_headers_filtered = recorded_request.headers.except(*headers_to_ignore)

    incoming_headers_filtered == recorded_headers_filtered
  end
end

# :reek:FeatureEnvy
# :reek:DuplicateMethodCall
# :reek:TooManyStatements
def sanitize_interaction(interaction)
  # Force UTF-8 encoding on response body to avoid encoding issues
  begin
    interaction.response.body.force_encoding('UTF-8')
  rescue StandardError
    nil
  end

  # Standardize Authorization header
  interaction.request.headers['Authorization'] = ['Bearer <token>'] if interaction.request.headers['Authorization']

  # Add or override specific headers to prevent cassette noise
  interaction.response.headers['Access-Control-Expose-Headers'] = ['access-control-expose-headers']
  interaction.response.headers['Etag'] = ['any-etag-cache-value']
  interaction.response.headers['X-Request-Id'] = ['x-request-id']

  # Sanitize access token in response body if present
  return unless interaction.request.uri.include?('access_tokens')

  content = parse_json(interaction.response.body)
  return unless content['token']

  content['token'] = '<token>'
  interaction.response.body = content.to_json
end

# :reek:UtilityFunction
# :reek:ControlParameter
def parse_nested_query(query)
  Rack::Utils.parse_nested_query(query || '')
rescue Rack::QueryParser::InvalidParameterError, URI::InvalidURIError
  {}
end

# :reek:UtilityFunction
def parse_json(string)
  JSON.parse(string)
rescue JSON::ParserError
  {}
end
# rubocop:enable Metrics/AbcSize
