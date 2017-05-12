class TwitterWrapper
  def initialize
    @streaming = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = Settings[:twitter][:consumer_key]
      config.consumer_secret     = Settings[:twitter][:consumer_secret]
      config.access_token        = Settings[:twitter][:access_token]
      config.access_token_secret = Settings[:twitter][:access_token_secret]
    end
    @rest = Twitter::REST::Client.new do |config|
      config.consumer_key        = Settings[:twitter][:consumer_key]
      config.consumer_secret     = Settings[:twitter][:consumer_secret]
      config.access_token        = Settings[:twitter][:access_token]
      config.access_token_secret = Settings[:twitter][:access_token_secret]
    end
  end

  def user_search(query)
    @rest.user_search(query).each do |user|
      hashed_item = {
        :id => user.id,
        :screen_name => user.screen_name,
        :name => user.name,
        :time_zone => user.time_zone,
        :utc_offset => user.utc_offset,
        :profile_image_url_https => user.profile_image_url_https.to_s,
      }
      yield hashed_item
    end
  end

  def stream(ids)
    @streaming.filter(:follow => ids.join(',')) do |object|
      yield object.text if object.is_a?(Twitter::Tweet)
    end
  end
end
