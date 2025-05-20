# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require_relative '../../../app/lib/http_client/http_client'

RSpec.describe HttpClient do
  include described_class

  let(:url) { 'https://example.com/test' }
  let(:fake_logger) { Logger.new(nil) }

  before do
    stub_const('Rails', Module.new)
    logger = fake_logger
    Rails.define_singleton_method(:logger) { logger }

    stub_request(:any, url).to_return(status: 200, body: '{}', headers: {})
  end

  describe 'connection integration with ConnectionBuilder' do
    it 'calls ConnectionBuilder with given timeouts' do
      payload = { foo: 'bar' }
      timeouts = { open_timeout: 1, read_timeout: 2, write_timeout: 3 }

      response_double = double('Response', body: '{}')

      # Spies ConnectionBuilder to ensure call using conn
      allow(HttpClient::ConnectionBuilder).to receive(:new).and_call_original

      expect(Faraday).to receive(:new)
        .with(hash_including(url: url, headers: anything, params: anything))
        .and_wrap_original do |original_method, *args, &block|
          conn = original_method.call(*args, &block)
          expect(HttpClient::ConnectionBuilder).to have_received(:new).with(conn, timeouts)
          allow(conn).to receive(:get).and_return(response_double)
          conn
        end

      get(url: url, payload: payload, timeouts: timeouts)
    end
  end

  describe '#get' do
    it 'sends a GET request with query params' do
      payload = { foo: 'bar' }

      response = double('Response', body: '{}')

      allow(Faraday).to receive(:new)
        .with(hash_including(params: payload))
        .and_wrap_original do |original_method, *args, &block|
          conn = original_method.call(*args, &block)
          allow(conn).to receive(:get).and_return(response)
          conn
        end

      result = get(url: url, payload: payload)
      expect(result).to eq(response)
    end
  end

  describe '#delete' do
    it 'sends a DELETE request with query params' do
      payload = { id: 123 }
      response = double('Response', body: '{}')

      allow(Faraday).to receive(:new)
        .with(hash_including(params: payload))
        .and_wrap_original do |original_method, *args, &block|
          conn = original_method.call(*args, &block)
          allow(conn).to receive(:delete).and_return(response)
          conn
        end

      result = delete(url: url, payload: payload)
      expect(result).to eq(response)
    end
  end

  describe '#post' do
    it 'sends a POST request with JSON body' do
      payload = { name: 'Test' }

      expect(Faraday).to receive(:new)
        .with(hash_including(params: {}))
        .and_wrap_original do |original_method, *args, &block|
          conn = original_method.call(*args) { |c| block&.call(c) }
          expect(conn).to receive(:post) do |&req_block|
            request = double('Request')
            expect(request).to receive(:body=).with(payload.to_json)
            req_block.call(request)
            double('Response', body: '{}')
          end
          conn
        end

      post(url: url, payload: payload)
    end
  end

  describe '#put' do
    it 'sends a PUT request with JSON body' do
      payload = { id: 1, name: 'Updated' }

      expect(Faraday).to receive(:new)
        .with(hash_including(params: {}))
        .and_wrap_original do |original_method, *args, &block|
          conn = original_method.call(*args) { |c| block&.call(c) }
          expect(conn).to receive(:put) do |&req_block|
            request = double('Request')
            expect(request).to receive(:body=).with(payload.to_json)
            req_block.call(request)
            double('Response', body: '{}')
          end
          conn
        end

      put(url: url, payload: payload)
    end
  end

  describe '#patch' do
    it 'sends a PATCH request with JSON body' do
      payload = { status: 'active' }

      expect(Faraday).to receive(:new)
        .with(hash_including(params: {}))
        .and_wrap_original do |original_method, *args, &block|
          conn = original_method.call(*args) { |c| block&.call(c) }
          expect(conn).to receive(:patch) do |&req_block|
            request = double('Request')
            expect(request).to receive(:body=).with(payload.to_json)
            req_block.call(request)
            double('Response', body: '{}')
          end
          conn
        end

      patch(url: url, payload: payload)
    end
  end
end
