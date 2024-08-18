# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramWebhook, :default_telegram_setup, type: :request do
  describe '/unsub some_streamer command' do
    let(:message_text) { '/unsub some_streamer' }

    before do
      allow(Streamer::UnsubscribingFromTwitchEventsJob).to receive(:perform_async)
    end

    context 'when subscribed to streamer' do
      it 'unsubscribes from streamer' do
        streamer = create(:streamer, :with_enabled_subscriptions, login: 'some_streamer')
        user.subscribe_to(streamer)

        streamer.event_subscriptions.pluck(:twitch_id)
        expected_text = I18n.t('streamer_subscription.unsubscribed', login: streamer.login)
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_users([user])

        expect { post '/telegram/webhook', message_params.to_json, headers }
          .to change { user.subscriptions.reload.count }.from(1).to(0)
          .and change { Streamer.count }.from(1).to(0)
      end
    end

    context 'when user has no subscriptions' do
      it 'returns a user not subscribed error' do
        create(:streamer, :with_enabled_subscriptions, login: 'some_streamer')
        expected_text = I18n.t('errors.user_not_subscribed', login: 'some_streamer')
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_users([user])

        expect { post '/telegram/webhook', message_params.to_json, headers }
          .to not_change { user.subscriptions.reload.count }
          .and not_change(Streamer, :count)
      end
    end

    context 'when streamer does not exist' do
      it 'returns a streamer not found error' do
        expected_text = I18n.t('errors.user_not_subscribed', login: 'some_streamer')
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_users([user])

        expect { post '/telegram/webhook', message_params.to_json, headers }
          .to not_change { user.subscriptions.reload.count }
          .and not_change(Streamer, :count)
      end
    end

    context 'when streamer has no event subscriptions' do
      it 'returns a generic error message' do
        streamer = create(:streamer, login: 'some_streamer')
        user.subscribe_to(streamer)

        expected_text = I18n.t('errors.generic')
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_users([user])
        expect(App.logger).to receive(:log_error)
          .with(instance_of(ActiveRecord::RecordNotDestroyed), 'Streamer Not Destroyed')

        expect { post '/telegram/webhook', message_params.to_json, headers }
          .to not_change { user.subscriptions.reload.count }
          .and not_change(Streamer, :count)
      end
    end
  end
end
