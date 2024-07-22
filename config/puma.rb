# frozen_string_literal: true

worker_timeout 3600 if ENV['RACK_ENV'] == 'development'

port ENV.fetch('PORT', 3000)
