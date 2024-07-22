# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)
require 'bundler/setup'
Bundler.require(:default, ENV.fetch('RACK_ENV', 'development'))
require 'telegram/bot'
