# frozen_string_literal: true

require 'active_support/deprecation'

ActiveSupport::Deprecation.behavior = :silence

ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)
OTR::ActiveRecord.configure_from_file!(App.root.join('config', 'database.yml'))
OTR::ActiveRecord.establish_connection!
