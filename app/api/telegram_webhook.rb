# frozen_string_literal: true

class TelegramWebhook < Grape::API
  format :json

  # If i respond with error status code, telegram will keep sending messsage.
  default_error_status 200
  rescue_from :all do |e|
    logger.log_error(e, 'Telegram webhook error')
    error!(message: 'Internal server error')
  end

  helpers do
    def valid_token?
      Rack::Utils.secure_compare(headers['x-telegram-bot-api-secret-token'], App.secrets.telegram_secret_token)
    end

    def handle_chat_member_status
      return unless params[:my_chat_member][:new_chat_member][:status] == 'kicked'

      User.find_by(chat_id: params[:my_chat_member][:chat][:id])&.destroy
    end
  end

  before do
    error!('Invalid token', 200) unless valid_token?
  end

  params do
    requires :update_id, type: Integer
    optional :message, type: Hash do
      requires :message_id, type: Integer
      requires :from, type: Hash do
        requires :id, type: Integer
        requires :is_bot, type: Boolean, values: [false], allow_blank: false
        requires :first_name, type: String
        optional :last_name, type: String
        optional :username, type: String
        optional :language_code, type: String
      end
      requires :chat, type: Hash do
        requires :id, type: Integer
        optional :first_name, type: String
        optional :last_name, type: String
        optional :username, type: String
        requires :type, type: String, values: ['private'], allow_blank: false
      end
      requires :date, type: Integer
      requires :text, type: String
      optional :entities, type: Array
    end
    optional :my_chat_member, type: Hash # this is when block/unblock bot https://core.telegram.org/bots/api#chatmemberupdated
    exactly_one_of :message, :my_chat_member
  end

  post '/webhook' do
    if params[:my_chat_member]
      handle_chat_member_status
      return_no_content
    else
      message = Telegram::Bot::Types::Update.new(params).current_message
      TelegramCommands::Invoker.new(message).execute
      status 200
    end
  end
end
