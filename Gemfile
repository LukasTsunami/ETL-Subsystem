# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.4'

gem 'blueprinter', '~> 1.0', '>= 1.0.2'
gem 'bootsnap', require: false
gem 'faraday'
gem 'faraday-retry'
gem 'httparty'
gem 'importmap-rails'
gem 'jbuilder'
gem 'jwt', '~> 1.5.4'
gem 'pg', '~> 1.5.9'
gem 'puma', '~> 6.0'
gem 'rack-cors', '~> 2.0.2'
gem 'rails', '~> 8.0.2'
gem 'redis', '~> 5.2'
gem 'sidekiq', '~> 7.2', '>= 7.2.4'
gem 'sidekiq-cron'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'dotenv-rails'
  gem 'factory_bot_rails', '~> 6.4', '>= 6.4.3'
  gem 'rspec-rails', '~> 8.0'
  gem 'shoulda-matchers'
  gem 'simplecov', '~> 0.22.0'
  gem 'vcr', '>= 6.3'
  gem 'webmock' # (ja vem com webmock/rspec internamente)
end

group :development do
  gem 'reek', '~> 6.3'
  gem 'rubocop', '~> 1.75'
  gem 'rubocop-performance', '~> 1.25'
  gem 'rubocop-rails', '~> 2.32'
  gem 'rubocop-rspec', '~> 3.6'
  gem 'web-console'
end
