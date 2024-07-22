# frozen_string_literal: true

Kredis.configurator = Class.new do
  def root = App.root

  def config_for(name)
    App.load_yaml_config("#{name}.yml")
  end
end.new

ActiveModel::API.include Kredis::Attributes if defined?(ActiveModel::API)
ActiveSupport.on_load(:active_record) { include Kredis::Attributes }
ActiveSupport::LogSubscriber.logger = ActiveSupport::Logger.new($stdout)

Kredis::Connections.connector = ->(config) { MockRedis.new(config) } if App.env == 'test'
