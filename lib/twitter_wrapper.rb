class TwitterWrapper
  def initialize
    @streaming = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = Settings.twitter.consumer_key
      config.consumer_secret     = Settings.twitter.consumer_secret
      config.access_token        = Settings.twitter.access_token
      config.access_token_secret = Settings.twitter.access_token_secret
    end
    @rest = Twitter::REST::Client.new do |config|
      config.consumer_key        = Settings.twitter.consumer_key
      config.consumer_secret     = Settings.twitter.consumer_secret
      config.access_token        = Settings.twitter.access_token
      config.access_token_secret = Settings.twitter.access_token_secret
    end
  end

  def user_search(query)
    @rest.user_search(query).each do |user|
      yield twitter_user_hash(user)
    end
  end

  def user(query)
    user = begin
      @rest.user(query)
    rescue Twitter::Error::NotFound
      raise TwitterUserNotFoundError
    end
    twitter_user_hash(user) if user.present?
  end

  def search(query)
    @rest.search(query, {count: 100, lang: 'ja'}).each do |tweet|
      yield tweet_hash(tweet)
    end
  end

  def user_timeline(id, since_id: nil)
    options = {count: 20}
    options[:since_id] = since_id if since_id.present?
    Rails.logger.debug "fetch timeline[#{id}]"
    Rails.logger.debug options
    begin
      @rest.user_timeline(id, options).each do |tweet|
        yield tweet_hash(tweet)
      end
    rescue Twitter::Error::NotFound
      raise TwitterUserNotFoundError
    end
  end

  def stream(ids)
    @streaming.filter(:follow => ids.join(',')) do |object|
      if object.is_a?(Twitter::Tweet)
        yield tweet_hash(object)
      end
    end
  end

  private
  def tweet_hash(tweet)
    {
      :id => tweet.id,
      :text => tweet.text.utf8mb4_encode,
      :created_at => tweet.created_at,
      :user => twitter_user_hash(tweet.user),
    }
  end

  def twitter_user_hash(user)
    {
      :id => user.id,
      :screen_name => user.screen_name,
      :name => user.name.utf8mb4_encode,
      :time_zone => user.time_zone,
      :utc_offset => user.utc_offset,
      :profile_image_url_https => user.profile_image_url_https.to_s,
    }
  end
end
class TwitterUserNotFoundError < StandardError; end
