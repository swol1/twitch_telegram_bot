# frozen_string_literal: true

class LoggerWithFormat < SimpleDelegator
  def log_error(err = nil, msg = nil)
    Sentry.capture_message "Error caught: #{err&.message}. Msg: #{msg}" if Object.const_defined?('Sentry')
    error(format_error_message(err, msg))
  end

  private

  def format_error_message(err, msg)
    error_message = ''
    error_message += "Timestamp: #{Time.now}\n"
    error_message += "Error: #{err.class} - #{err.message}\n" if err
    error_message += "Message: #{msg}\n" if msg
    error_message += "Backtrace:\n#{format_backtrace(err.backtrace)}" if err&.backtrace
    error_message
  end

  def format_backtrace(backtrace)
    backtrace[0, 20].map { |line| "  #{line}" }.join("\n")
  end
end
