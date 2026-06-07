# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchWebhook, :default_twitch_setup, type: :request do
  let(:new_login) { 'new_login' }
  let(:new_name)  { 'New Name' }
  let(:params) do
    base_params.deep_merge(
      event: {
        user_name: new_name,
        user_login: new_login
      }
    )
  end
  let(:event_subscription) { streamer.event_subscriptions.find_by(event_type: 'user.update') }

  subject(:send_request) { post '/twitch/eventsub', params.to_json, headers }

  before { allow(TwitchEvents::DeliverNotificationJob).to receive(:perform_in) }

  describe 'POST user.update event' do
    context 'when user info changed' do
      before { streamer.update!(login: 'old_login', name: 'Old Name') }

      it 'updates streamer login and name' do
        expect { send_request }
          .to change { streamer.reload.login }.from('old_login').to(new_login)
          .and change { streamer.reload.name }.from('Old Name').to(new_name)
      end

      it 'notifies subscribers' do
        chats = create_list(:chat, 3, subscriptions: [streamer])
        notification_data = { 'old_name' => 'Old Name', 'login' => new_login, 'name' => new_name }

        send_request

        expect(TwitchEvents::DeliverNotificationJob).to have_received(:perform_in).exactly(chats.size).times
        chats.each do |chat|
          expect(TwitchEvents::DeliverNotificationJob).to have_received(:perform_in)
            .with(0, chat.id, streamer.id, 'user.update', notification_data)
        end
        expect(last_response.status).to eq(204)
      end
    end
  end
end
