# frozen_string_literal: true

class TwitchEvent::ProcessJob
  include Sidekiq::Job
  sidekiq_options retry: 1

  def perform(params)
    event = TwitchEvent.new(params)
    if event.valid? && event.not_duplicated?
      process_event(event)
    else
      App.logger.log_error(
        nil,
        "Event was not processed: #{event.inspect}. " \
        "valid: #{event.valid?}, not_duplicated: #{event.not_duplicated?}"
      )
    end
  end

  private

  def process_event(event)
    "TwitchEvents::#{event.type.tr('.', '_').classify}".constantize.new(event).process
  end
end
