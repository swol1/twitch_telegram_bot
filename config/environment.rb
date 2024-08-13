# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require 'dotenv'

env_files = {
  'production' => '.env',
  'development' => '.env.local',
  'test' => '.env.test'
}
Dotenv.load(env_files.fetch(ENV.fetch('RACK_ENV', nil), 'test'))

require_relative 'boot'
require_relative 'application'
require_relative 'zeitwerk'
