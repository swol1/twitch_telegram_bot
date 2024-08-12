# frozen_string_literal: true

class AddTwitchIdToEventSubscriptions < ActiveRecord::Migration[7.1]
  def change
    add_column :event_subscriptions, :twitch_id, :string
    add_index :event_subscriptions, :twitch_id, unique: true
  end
end
