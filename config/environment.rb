# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require 'dotenv'
Dotenv.load(".env.#{ENV.fetch('RACK_ENV', nil)}", '.env')

require_relative 'boot'
require_relative 'application'
require_relative 'zeitwerk'
