# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TelegramWebhook, :default_telegram_setup, type: :request do
  describe '/sub some_streamer command' do
    let(:message_text) { '/sub some_streamer' }

    subject(:send_request) { post '/telegram/webhook', message_params.to_json, headers }

    before do
      allow(Streamer::SubscribeToTwitchEventsJob).to receive(:perform_async)
      allow(Streamer::ReconcileEnabledTwitchEventsJob).to receive(:perform_in)
    end

    context 'when login not provided' do
      let(:message_text) { '/sub' }

      it 'sends error' do
        expected_text = I18n.t('errors.login_not_provided')
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

        send_request
      end
    end

    context 'when chat reached max amount of subscriptions' do
      it 'sends error' do
        streamers = create_list(:streamer, 2)
        chat.subscriptions << streamers

        expected_text = I18n.t('errors.max_subs_reached', max_subs: 2)
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

        expect { send_request }.not_to(change { chat.subscriptions.reload.count })
      end
    end

    context 'when twitch client responds with success' do
      before do
        allow(twitch_api_client).to receive(:get_streamer).with('some_streamer').and_return(
          success_response(data: [{ login: 'some_streamer', id: 'twitch_1', display_name: 'SomeStreamer' }])
        )
        allow(twitch_api_client).to receive(:get_channel_info).with('twitch_1').and_return(
          success_response(data: [{ game_name: 'some_game', title: 'my title t.me/my_tg_login' }])
        )
      end

      it 'subscribes chat to streamer' do
        expect { send_request }.to change { chat.subscriptions.reload.count }.by(+1)

        streamer = Streamer.last
        expect(chat.subscriptions.last).to eq(streamer)
      end

      it 'returns message with streamer info' do
        expected_text = <<~TEXT.strip
          You have successfully subscribed to notifications from <b>SomeStreamer</b>.
          Number of available subscriptions: 1

          Category: some_game
          Title: my title t.me/my_tg_login
          twitch: https://twitch.tv/some_streamer
          telegram: https://t.me/my_tg_login
        TEXT
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

        send_request
      end

      context 'when streamer info not available' do
        it 'returns message without streamer info' do
          allow(twitch_api_client).to receive(:get_channel_info)
            .with('twitch_1')
            .and_return(success_response(data: [{}]))

          expected_text = <<~TEXT.strip
            You have successfully subscribed to notifications from <b>SomeStreamer</b>.
            Number of available subscriptions: 1
          TEXT
          expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

          send_request
        end
      end

      context 'when chat already subscribed to the streamer' do
        it 'sends error' do
          streamer = Streamer.create(login: 'some_streamer', twitch_id: 'twitch_1', name: 'SomeStreamer')
          chat.subscriptions << streamer

          expected_text = I18n.t('errors.not_uniq_subscription', name: streamer.name)
          expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

          expect { send_request }.not_to(change { chat.subscriptions.reload.count })
        end
      end
    end

    context 'when streamer not found' do
      before do
        allow(twitch_api_client).to receive(:get_streamer).with('some_streamer').and_return(not_found_response)
      end

      it 'sends error message' do
        expected_text = I18n.t('errors.streamer_not_found', login: 'some_streamer')
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

        send_request
      end
    end

    context 'when streamer invalid' do
      before do
        allow(twitch_api_client).to receive(:get_streamer).with('some_streamer').and_return(
          success_response(data: [{ login: 'some_streamer', id: 'twitch_1', display_name: '' }])
        )
      end

      it 'sends error message' do
        expected_text = I18n.t('errors.generic')
        expect(telegram_bot_client).to receive_send_message_with(text: expected_text).to_chats([chat])

        send_request
      end
    end
  end
end
