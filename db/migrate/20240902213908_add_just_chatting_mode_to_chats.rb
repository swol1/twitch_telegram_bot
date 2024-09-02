# frozen_string_literal: true

class AddJustChattingModeToChats < ActiveRecord::Migration[7.1]
  def change
    add_column :chats, :just_chatting_mode, :boolean, default: false
  end
end
