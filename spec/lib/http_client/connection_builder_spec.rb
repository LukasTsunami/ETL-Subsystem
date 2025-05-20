# frozen_string_literal: true

require 'spec_helper'
require 'webmock/rspec'
require 'faraday'
require 'faraday/retry'
require_relative '../../../app/lib/http_client/connection_builder'

RSpec.describe HttpClient::ConnectionBuilder do
  let(:fake_logger) { Logger.new(nil) }

  let(:conn) do
    Faraday.new(url: 'https://example.com') do |f|
      # connection will be configured later
    end
  end

  before do
    stub_const('Rails', Module.new)
    logger = fake_logger
    Rails.define_singleton_method(:logger) { logger }
  end

  describe '#configure' do
    context 'with custom timeouts' do
      let(:timeouts) { { open_timeout: 3, read_timeout: 7, write_timeout: 9 } }

      it 'applies the custom timeout values' do
        described_class.new(conn, timeouts).configure

        expect(conn.options.open_timeout).to eq(3)
        expect(conn.options.read_timeout).to eq(7)
        expect(conn.options.write_timeout).to eq(9)
      end
    end

    context 'with no timeouts provided' do
      let(:timeouts) { {} }

      it 'applies the default timeout values' do
        described_class.new(conn, timeouts).configure
        conn_options = conn.options
        open_timeout = HttpClient::ConnectionBuilder::DEFAULT_TIMEOUTS_IN_SECONDS[:open_timeout]
        read_timeout = HttpClient::ConnectionBuilder::DEFAULT_TIMEOUTS_IN_SECONDS[:read_timeout]
        write_timeout = HttpClient::ConnectionBuilder::DEFAULT_TIMEOUTS_IN_SECONDS[:write_timeout]
        expect(conn_options.open_timeout).to eq(open_timeout)
        expect(conn_options.read_timeout).to eq(read_timeout)
        expect(conn_options.write_timeout).to eq(write_timeout)
      end
    end

    it 'configures required middlewares' do
      builder = described_class.new(conn, {})
      builder.configure

      middleware_classes = conn.builder.handlers.map(&:name)

      expect(middleware_classes).to include('Faraday::Response::RaiseError')
      expect(middleware_classes).to include('Faraday::Retry::Middleware')
      expect(middleware_classes).to include('Faraday::Response::Logger')
    end
  end
end
