# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'

require 'dotenv'

env_files = {
  'development' => '.env.local',
  'test' => '.env.test'
}
env_file = env_files[ENV.fetch('RACK_ENV', nil)]
Dotenv.load(env_file) if env_file

require_relative 'boot'
require_relative 'application'
require_relative 'zeitwerk'
