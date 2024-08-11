# frozen_string_literal: true

class TwitchWebhook < Grape::API
  TWITCH_MESSAGE_ID = 'twitch-eventsub-message-id'
  TWITCH_MESSAGE_TIMESTAMP = 'twitch-eventsub-message-timestamp'
  TWITCH_MESSAGE_SIGNATURE = 'twitch-eventsub-message-signature'
  TWITCH_MESSAGE_TYPE = 'twitch-eventsub-message-type'

  MESSAGE_TYPE_VERIFICATION = 'webhook_callback_verification'
  MESSAGE_TYPE_NOTIFICATION = 'notification'
  MESSAGE_TYPE_REVOCATION = 'revocation'

  rescue_from :all do |e|
    logger.log_error(e, 'Twitch webhook error')
    error!(message: 'Internal server error', status: 500)
  end

  helpers do
    def verify_twitch_signature
      secret = App.secrets.twitch_message_secret
      message = [
        headers[TWITCH_MESSAGE_ID],
        headers[TWITCH_MESSAGE_TIMESTAMP],
        params.to_json
      ].join
      computed_signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, message)
      expected_signature = headers[TWITCH_MESSAGE_SIGNATURE]&.split('=')&.last
      Rack::Utils.secure_compare(computed_signature, expected_signature)
    end

    def event_subscription
      @_event_subscription ||= EventSubscription.find_by!(twitch_id: params['subscription']['id'])
    end

    def event_params
      event = params['event']
      {
        id: headers[TWITCH_MESSAGE_ID],
        type: params['subscription']['type'],
        twitch_id: params['subscription']['id'],
        category: event['category_name'],
        title: event['title'],
        received_at: Time.current.iso8601
      }.stringify_keys
    end
  end

  before do
    error!('Invalid signature', 403) unless verify_twitch_signature
  end

  params do
    requires :subscription, type: Hash do
      requires :id, type: String
      requires :type, type: String
      requires :version, type: String
      requires :condition, type: Hash do
        requires :broadcaster_user_id, type: String
      end
    end
    optional :event, type: Hash do
      optional :broadcaster_user_id, type: String
      optional :broadcaster_user_login, type: String
      optional :broadcaster_user_name, type: String
      optional :category_name, type: String
      optional :title, type: String
    end
  end

  post '/eventsub' do
    case request.headers[TWITCH_MESSAGE_TYPE]
    when MESSAGE_TYPE_VERIFICATION
      event_subscription.enabled!
      content_type 'text/plain'
      status 200
      body params['challenge']
    when MESSAGE_TYPE_NOTIFICATION
      TwitchEvent::ProcessJob.perform_async(event_params)
      return_no_content
    when MESSAGE_TYPE_REVOCATION
      event_subscription.revoked!
      streamer = event_subscription.streamer
      streamer.destroy if streamer.event_subscriptions.all?(&:revoked?)

      App.logger.log_error(nil, "Event Revoked: #{event_subscription.inspect}")
      return_no_content
    else
      return_no_content
    end
  end
end
