# frozen_string_literal: true

class TwitchEvent::ProcessJob
  include Sidekiq::Job
  sidekiq_options retry: 1

  def perform(params)
    event = TwitchEvent.new(params)

    return unless event.valid? && event.not_duplicated?

    "TwitchEvents::#{event.type.tr('.', '_').classify}".constantize.new(event).process
  end
end
