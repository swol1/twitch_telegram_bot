# frozen_string_literal: true

App.logger = LoggerWithFormat.new(Logger.new($stdout))
