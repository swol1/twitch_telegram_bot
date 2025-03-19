# frozen_string_literal: true

desc 'Destroy all streamers that are not used'
task destroy_unused_streamers: :environment do
  removed_streamers = []
  skipped_streamers = []
  twitch_api_client = TwitchApiClient.new
  streamers = Streamer
              .includes(:event_subscriptions)
              .left_joins(:chat_streamer_subscriptions)
              .where(chat_streamer_subscriptions: { id: nil })

  streamers.find_each do |streamer|
    event_subscriptions = streamer.event_subscriptions
    if event_subscriptions.any?(&:pending?)
      App.logger.log_error(nil, "Streamer #{streamer.id} was not destroyed: pending event subscriptions exist")
      skipped_streamers << { id: streamer.id, name: streamer.name, reason: 'pending event subscriptions' }
      next
    end

    unless event_subscriptions.all?(&:revoked?)
      event_subscriptions.pluck(:twitch_id).each do |twitch_id|
        response = twitch_api_client.delete_subscription_to_event(twitch_id)
        next if %w[204 404].include?(response[:status])

        App.logger.log_error(
          nil,
          "Subscription was not deleted: #{twitch_id}. Response: #{response.inspect}"
        )
      end
    end

    ActiveRecord::Base.transaction do
      event_subscriptions.destroy_all
      streamer.destroy!
    end
    removed_streamers << { id: streamer.id, name: streamer.name }
  end

  puts "\n=== Removal Summary ==="
  if removed_streamers.any?
    puts "Total removed streamers: #{removed_streamers.count}"
    removed_streamers.each { puts " - Streamer #{_1[:id]} (#{_1[:name]}) removed." }
  else
    puts 'No streamers were removed.'
  end

  if skipped_streamers.any?
    puts "\nStreamers skipped due to pending subscriptions:"
    skipped_streamers.each { puts " - Streamer #{_1[:id]} (#{_1[:name]})" }
  end
end
