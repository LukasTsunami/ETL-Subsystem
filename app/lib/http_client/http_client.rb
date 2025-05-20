# frozen_string_literal: true

require 'faraday'
require 'faraday/retry'

# :reek:DataClump
# :reek:DuplicateMethodCall
# :reek:LongParameterList
# :reek:TooManyStatements
# Module used to make REST requests using Faraday
module HttpClient
  def get(url:, payload: {}, headers: {}, timeouts: {})
    request(method: :get, url:, payload:, headers:, timeouts:)
  end

  def post(url:, payload: {}, headers: {}, timeouts: {})
    request(method: :post, url:, payload:, headers:, timeouts:)
  end

  def put(url:, payload: {}, headers: {}, timeouts: {})
    request(method: :put, url:, payload:, headers:, timeouts:)
  end

  def patch(url:, payload: {}, headers: {}, timeouts: {})
    request(method: :patch, url:, payload:, headers:, timeouts:)
  end

  def delete(url:, payload: {}, headers: {}, timeouts: {})
    request(method: :delete, url:, payload:, headers:, timeouts:)
  end

  def self.parse_json(response)
    JSON.parse(response.body, symbolize_names: true)
  end

  def request(method:, url:, payload:, headers:, timeouts:)
    params = %i[get delete head].include?(method) ? payload : {}
    body = %i[post put patch].include?(method) ? payload.to_json : nil

    http_client(
      url:,
      headers: default_headers.merge(headers),
      params:,
      timeouts:
    ).send(method) do |req|
      req.body = body if body
    end
  end

  def default_headers
    {
      'Content-Type' => 'application/json',
      'Accept' => 'application/json'
    }
  end

  # :reek:UtilityFunction
  def http_client(url:, headers:, params:, timeouts:)
    Faraday.new(url:, headers:, params:) do |conn|
      ConnectionBuilder.new(conn, timeouts).configure
    end
  end
end
