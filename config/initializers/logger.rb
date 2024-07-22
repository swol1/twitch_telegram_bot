# frozen_string_literal: true

log_file_path = App.root.join('log', "#{App.env}.log")
FileUtils.mkdir_p(File.dirname(log_file_path))

log_file = File.open(log_file_path, 'a')
log_file.sync = true

App.logger = LoggerWithFormat.new(Logger.new(GrapeLogging::MultiIO.new($stdout, log_file), 'weekly'))
