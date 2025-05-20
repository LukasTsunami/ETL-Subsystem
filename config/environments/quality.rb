# frozen_string_literal: true

require_relative 'production'

Rails.application.configure do
  # Override any production-specific settings here

  config.hosts.clear
end
