# frozen_string_literal: true

class CreateStreamers < ActiveRecord::Migration[7.1]
  def change
    create_table :streamers do |t|
      t.string :login, null: false, index: { unique: true }
      t.string :name, null: false
      t.string :twitch_id, null: false, index: { unique: true }
      t.string :telegram_login, index: { unique: true }

      t.timestamps
    end
  end
end
