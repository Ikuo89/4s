require 'line/bot'
class LineBotWrapper
  def initialize(event)
    @client = self.class.client
    @event = event
  end

  def type
    @event.type
  end

  def message
    @event.message
  end

  def text
    @event.message['text'] if @event.message.present?
  end

  def room_id
    @event['source']['groupId'] || @event['source']['roomId'] || @event['source']['userId']
  end

  def reply_message(message)
    message = {
      type: 'text',
      text: message
    }
    @client.reply_message(@event['replyToken'], message)
  end

  class << self
    def client
      return @client if @client.present?
      @client = Line::Bot::Client.new { |config|
        config.channel_secret = Settings[:line][:channel_secret]
        config.channel_token = Settings[:line][:channel_token]
      }
    end

    def parse_each(body, signature)
      unless self.client.validate_signature(body, signature)
        raise ActionController::BadRequest.new
      end

      result = []
      events = self.client.parse_events_from(body)
      events.each do |event|
        yield LineBotWrapper.new(event)
      end
    end
  end
end
