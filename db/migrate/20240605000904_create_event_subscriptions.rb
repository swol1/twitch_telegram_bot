# frozen_string_literal: true

class CreateEventSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :event_subscriptions do |t|
      t.string :event_type, null: false
      t.string :streamer_twitch_id, null: false
      t.string :version, null: false
      t.integer :status, null: false

      t.timestamps
    end

    add_index :event_subscriptions, %i[streamer_twitch_id event_type], unique: true
  end
end
