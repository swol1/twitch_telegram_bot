# frozen_string_literal: true

desc 'Destroy all streamers that are not used'
task destroy_unused_streamers: :environment do
  streamers = Streamer.left_outer_joins(:chat_streamer_subscriptions)
                      .where(chat_streamer_subscriptions: { id: nil })

  streamers.each do |streamer|
    event_subscriptions = streamer.event_subscriptions
    if event_subscriptions.any?(&:pending?)
      App.logger.log_error(nil, "Streamer #{streamer.id} was not destroyed: pending event subscriptions exist")
      next
    end

    unless event_subscriptions.all?(&:revoked?)
      event_subscriptions.pluck(:twitch_id).each do |twitch_id|
        response = TwitchApiClient.new.delete_subscription_to_event(twitch_id)
        next if %w[204 404].include?(response[:status])

        App.logger.log_error(
          nil,
          "Subscription was not deleted: #{twitch_id}. Response: #{response.inspect}"
        )
      end
    end

    ActiveRecord::Base.transaction do
      event_subscriptions.destroy_all
      streamer.destroy
    end
  end
end
