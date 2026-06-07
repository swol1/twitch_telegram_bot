# frozen_string_literal: true

require 'spec_helper'

RSpec.describe TwitchWebhook, :default_twitch_setup, type: :request do
  let(:params) do
    base_params.deep_merge(
      event: {
        category_name: 'some_category',
        title: 'some_title t.me/my_tg_login'
      }
    )
  end
  let(:event_subscription) { streamer.event_subscriptions.find_by(event_type: 'channel.update') }

  subject(:send_request) { post '/twitch/eventsub', params.to_json, headers }

  before { allow(TwitchEvents::DeliverNotificationJob).to receive(:perform_in) }

  describe 'POST channel.update event' do
    context 'when values changed' do
      before { streamer.channel_info.update(title: 'title', category: 'category', status: 'online') }

      it 'updates streamer data' do
        expect { send_request }
          .to change { streamer.reload.telegram_login }.from(nil).to('my_tg_login')
          .and change { streamer.channel_info[:title] }.from('title').to('some_title t.me/my_tg_login')
          .and change { streamer.channel_info[:category] }.from('category').to('some_category')
      end

      it 'notifies subscribers' do
        chats = create_list(:chat, 3, subscriptions: [streamer])
        notification_data = {
          'category' => 'some_category',
          'title' => 'some_title t.me/my_tg_login',
          'changed_fields' => %w[category title]
        }

        send_request

        expect(TwitchEvents::DeliverNotificationJob).to have_received(:perform_in).exactly(chats.size).times
        chats.each do |chat|
          expect(TwitchEvents::DeliverNotificationJob).to have_received(:perform_in)
            .with(0, chat.id, streamer.id, 'channel.update', notification_data)
        end
        expect(last_response.status).to eq(204)
      end
    end

    context 'when values the same' do
      before { streamer.channel_info.update(title: 'some_title t.me/my_tg_login', category: 'some_category') }

      it 'doesn\'t update streamer data' do
        expect { send_request }
          .to not_change { streamer.reload.telegram_login }
          .and not_change { streamer.channel_info[:title] }
          .and(not_change { streamer.channel_info[:category] })
      end

      it 'doesn\'t notify chats' do
        send_request

        expect(TwitchEvents::DeliverNotificationJob).not_to have_received(:perform_in)
        expect(last_response.status).to eq(204)
      end
    end

    context 'when telegram login already set' do
      it "doesn't update telegram login" do
        streamer.update(telegram_login: 'other_login')
        expect { send_request }.to change { streamer.reload.telegram_login }
          .from('other_login')
          .to('my_tg_login')
      end
    end

    context 'when chat has just chatting mode is on' do
      it 'doesn\'t notify them if category is not Just Chatting' do
        chat_with_jc_mode = create(:chat, just_chatting_mode: true, subscriptions: [streamer])
        chat_without_jc_mode = create(:chat, subscriptions: [streamer])

        send_request

        expect(TwitchEvents::DeliverNotificationJob).not_to have_received(:perform_in)
          .with(anything, chat_with_jc_mode.id, anything, anything, anything)
        expect(TwitchEvents::DeliverNotificationJob).to have_received(:perform_in)
          .with(
            0,
            chat_without_jc_mode.id,
            streamer.id,
            'channel.update',
            hash_including('category' => 'some_category')
          )
        expect(last_response.status).to eq(204)
      end

      it 'notifies all chats if category is Just Chatting' do
        chat_with_jc_mode = create(:chat, just_chatting_mode: true, subscriptions: [streamer])
        chat_without_jc_mode = create(:chat, subscriptions: [streamer])

        post '/twitch/eventsub', params.deep_merge(event: { category_name: 'Just Chatting' }).to_json, headers

        [chat_with_jc_mode, chat_without_jc_mode].each do |chat|
          expect(TwitchEvents::DeliverNotificationJob).to have_received(:perform_in)
            .with(
              0,
              chat.id,
              streamer.id,
              'channel.update',
              hash_including('category' => 'Just Chatting')
            )
        end
        expect(last_response.status).to eq(204)
      end
    end
  end
end
