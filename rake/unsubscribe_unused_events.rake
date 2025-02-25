# frozen_string_literal: true

desc 'Unsubscribes from all twitch events that are not used'
task unsubscribe_unused_events: :environment do
  twitch_api_client = TwitchApiClient.new
  all_subscriptions = twitch_api_client.get_all_app_subscriptions
  all_subscriptions[:body][:data].each do |s|
    next if EventSubscription.exists?(twitch_id: s[:id])
    next if s[:status] == 'webhook_callback_verification_pending'

    twitch_api_client.delete_subscription_to_event(s[:id])
  end
end
