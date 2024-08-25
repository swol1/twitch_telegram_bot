# frozen_string_literal: true

class UpdateChatIdAndRemoveTelegramId < ActiveRecord::Migration[7.1]
  def change
    remove_index :users, :telegram_id
    remove_column :users, :telegram_id, :bigint

    remove_index :users, :chat_id
    remove_column :users, :chat_id, :bigint

    rename_column :users, :encrypted_chat_id, :chat_id

    change_column :users, :chat_id, :string, null: false
    add_index :users, :chat_id, unique: true
  end
end