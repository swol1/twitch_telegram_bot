# frozen_string_literal: true

loader = Zeitwerk::Loader.new
app_folders = %w[api jobs models presenters services]
app_folders.each { |folder| loader.push_dir(App.root.join('app', folder)) }
loader.push_dir(App.root.join('lib'))

loader.enable_reloading if App.env.development?
loader.logger = nil # method(:puts) if App.env.development?
loader.setup

Dir["#{__dir__}/initializers/**/*.rb"].each { |f| require f }

loader.eager_load unless App.env.development?
