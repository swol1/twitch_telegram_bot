# frozen_string_literal: true

require_relative 'logger_with_format'

class App
  class << self
    attr_accessor :logger

    def env
      @_env ||= ActiveSupport::StringInquirer.new(ENV.fetch('RACK_ENV', 'development'))
    end

    def root
      @_root ||= Pathname.new(File.expand_path('../', __dir__))
    end

    def secrets
      @_secrets ||= Hashie::Mash.new(load_yaml_config('secrets.yml'))
    end

    def load_yaml_config(filename)
      yaml_content = ERB.new(File.read(root.join('config', filename))).result
      YAML.safe_load(yaml_content, aliases: true).deep_symbolize_keys[env.to_sym]
    end
  end
end
