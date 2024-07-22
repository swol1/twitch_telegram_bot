# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :locale, null: false
      t.bigint :telegram_id, null: false, index: { unique: true }
      t.bigint :chat_id, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
