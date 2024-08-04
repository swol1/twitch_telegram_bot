# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require 'dotenv'

env_file = ENV['RACK_ENV'] == 'production' ? '.env' : '.env.local'
Dotenv.load(env_file)

require_relative 'boot'
require_relative 'application'
require_relative 'zeitwerk'
