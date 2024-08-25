# frozen_string_literal: true

class AddEncryptedChatIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :encrypted_chat_id, :string
  end
end
