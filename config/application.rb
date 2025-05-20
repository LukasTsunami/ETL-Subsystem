# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Myapp 
  # Initialize configuration defaults for originally generated Rails version.
  class Application < Rails::Application
    config.load_defaults 7.1

    config.autoload_paths << Rails.root.join('app/services/**/')
    config.autoload_paths << Rails.root.join("app/lib")
    config.eager_load_paths << Rails.root.join("app/lib")
    
    config.autoload_lib(ignore: %w[assets tasks])

    # config.middleware.use "Rack::Cors" do
    #   allow do
    #     origins 'http://localhost:3005'
    #     resource '*', :headers => :any, :methods => [:get, :post, :delete, :put, :options]
    #   end
    # end
  end
end
