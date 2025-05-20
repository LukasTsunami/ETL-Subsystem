# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'

module HttpClient
  # Responsible to configure Faraday connection object
  class ConnectionBuilder
    DEFAULT_TIMEOUTS_IN_SECONDS = {
      open_timeout: 5,
      read_timeout: 10,
      write_timeout: 10
    }.freeze

    def initialize(conn, timeouts)
      @conn = conn
      @conn_options = @conn.options
      @timeouts = timeouts
    end

    def configure
      apply_timeouts
      apply_middleware
    end

    private

    def apply_timeouts
      merged = DEFAULT_TIMEOUTS_IN_SECONDS.merge(@timeouts)

      @conn_options.open_timeout = merged[:open_timeout]
      @conn_options.read_timeout = merged[:read_timeout]
      @conn_options.write_timeout = merged[:write_timeout]
    end

    def apply_middleware
      @conn.use Faraday::Response::RaiseError
      @conn.request :retry, retry_options
      @conn.response :logger, Rails.logger, headers: true, bodies: true, log_level: :debug
      @conn.adapter Faraday.default_adapter
    end

    def retry_options
      {
        max: 3,
        interval: 0.05,
        interval_randomness: 0.5,
        methods: [:get]
      }
    end
  end
end
