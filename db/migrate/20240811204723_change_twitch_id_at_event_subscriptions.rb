# frozen_string_literal: true

class ChangeTwitchIdAtEventSubscriptions < ActiveRecord::Migration[7.1]
  def change
    change_column :event_subscriptions, :twitch_id, :string, null: false
  end
end
