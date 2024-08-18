#!/usr/bin/env rake
# frozen_string_literal: true

require 'bundler/setup'

ENV['RACK_ENV'] ||= 'development'

begin
  Bundler.setup :default, ENV.fetch('RACK_ENV')
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'rake'

Dir.glob(File.join(__dir__, 'rake', '**', '*.rb')).each(&method(:require))

task :environment do
  require File.expand_path('config/environment.rb', __dir__)
end

desc 'Lists all of the routes'
task routes: :environment do
  Root.routes.each do |route|
    method = route.request_method.ljust(10)
    path = route.origin
    puts "      #{method} #{path}"
  end
end

load 'tasks/otr-activerecord.rake'

namespace :db do
  task :environment do
    require File.expand_path('config/application.rb', __dir__)
    require File.expand_path('config/initializers/otr_activerecord.rb', __dir__)
  end
end
