# frozen_string_literal: true

require File.expand_path('config/environment', __dir__)

use OTR::ActiveRecord::ConnectionManagement
use Rack::Attack

Root.compile!
run Root
