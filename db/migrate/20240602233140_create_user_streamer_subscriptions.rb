# frozen_string_literal: true

class CreateUserStreamerSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :user_streamer_subscriptions do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :streamer, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_streamer_subscriptions, %i[user_id streamer_id], unique: true
  end
end
