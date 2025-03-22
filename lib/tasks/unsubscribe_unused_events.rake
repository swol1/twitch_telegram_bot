# frozen_string_literal: true

desc 'Unsubscribes from all twitch events that are not used'
task unsubscribe_unused_events: :environment do
  twitch_api_client = TwitchApiClient.new
  all_subscriptions = twitch_api_client.get_all_app_subscriptions
  removed_count = 0
  # checking each record is not efficient, but the number of records is small
  # maybe improve this in the future
  all_subscriptions[:body][:data].each do |s|
    next if EventSubscription.exists?(twitch_id: s[:id])
    next if s[:status] == 'webhook_callback_verification_pending'

    twitch_api_client.delete_subscription_to_event(s[:id])

    response = twitch_api_client.delete_subscription_to_event(s[:id])
    if response[:status] == '204'
      removed_count += 1
      puts "Successfully unsubscribed from twitch event for subscription #{twitch_id}."
    else
      puts "Failed to unsubscribe twitch event for subscription #{twitch_id}. Response: #{response.inspect}"
    end
  end
  puts "Unsubscribed from #{removed_count} unused twitch events."
end
