# frozen_string_literal: true

require 'active_support/deprecation'
require 'active_record/encryption'

ActiveSupport::Deprecation.behavior = :silence

ActiveRecord::Base.logger = ActiveSupport::Logger.new($stdout)
OTR::ActiveRecord.configure_from_file!(App.root.join('config', 'database.yml'))
OTR::ActiveRecord.establish_connection!

ActiveRecord::Encryption.configure(
  primary_key: App.secrets.db_encryption_primary_key,
  deterministic_key: App.secrets.db_encryption_deterministic_key,
  key_derivation_salt: App.secrets.db_encryption_key_derivation_salt,
  extend_queries: true
)
