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
      yield twitter_user_hash(user)
    end
  end

  def stream(ids)
    @streaming.filter(:follow => ids.join(',')) do |object|
      if object.is_a?(Twitter::Tweet)
        hashed_item = {
          :id => object.id,
          :text => object.text,
          :user => twitter_user_hash(object.user),
        }
        yield hashed_item
      end
    end
  end

  private
  def twitter_user_hash(user)
    {
      :id => user.id,
      :screen_name => user.screen_name,
      :name => user.name,
      :time_zone => user.time_zone,
      :utc_offset => user.utc_offset,
      :profile_image_url_https => user.profile_image_url_https.to_s,
    }
  end
end
