# frozen_string_literal: true

class RenameUsersToChats < ActiveRecord::Migration[7.1]
  def change
    rename_table :users, :chats
    rename_table :user_streamer_subscriptions, :chat_streamer_subscriptions
    rename_column :chats, :chat_id, :telegram_id
    rename_column :chat_streamer_subscriptions, :user_id, :chat_id
  end
end