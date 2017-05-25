class TwitterService
  class << self
    def user_search(query)
      twitter_client.user_search(query) do |user_hash|
        yield TwitterUser.parse(user_hash)
      end
    end

    def create(twitter_com_user_id)
      user_hash = twitter_client.user(twitter_com_user_id)
      raise TwitterUserNotFoundError if user_hash.blank?

      twitter_user = TwitterUser.insert_or_update!(user_hash)
    end

    def watch_user_timeline
      user_ids = []
      TwitterUser.all.each do |user|
        user_ids << user.twitter_com_user_id
      end

      twitter_client.stream(user_ids) do |tweet_hash|
        analyze_tweet(tweet_hash)

        TwitterUser.insert_or_update!(tweet_hash[:user]) if user_ids.include?(tweet_hash[:user])
      end
    end

    def fetch_user_timeline
      TwitterUser.all.each do |user|
        tweet = user.twitter_tweets.order(twitter_com_tweet_id: :desc).first
        since_id = nil
        since_id = tweet.twitter_com_tweet_id if tweet.present?
        twitter_user_hash = nil
        twitter_client.user_timeline(user.screen_name, since_id: since_id) do |tweet_hash|
          analyze_tweet(tweet_hash)

          if tweet_hash[:user][:id] == user.twitter_com_user_id
            twitter_user_hash = tweet_hash[:user]
          end
        end

        TwitterUser.insert_or_update!(twitter_user_hash) if twitter_user_hash.present?
      end
    end

    private
    def twitter_client
      @twitter = TwitterWrapper.new if @twitter.blank?
      @twitter
    end

    def analyze_tweet(tweet_hash)
      twitter_user = TwitterUser.find_by(twitter_com_user_id: tweet_hash[:user][:id])
      return if twitter_user.blank?

      tweet = TwitterTweet.find_by(twitter_com_tweet_id: tweet_hash[:id])
      return if tweet.present?

      tweet = twitter_user.twitter_tweets.build(
        twitter_com_tweet_id: tweet_hash[:id],
        text: tweet_hash[:text],
      )
      tweet.save!

      if twitter_user.calendars.present?
        event = Event.parse_from_text(tweet_hash[:text], time_zone: tweet_hash[:user][:time_zone], target_date: tweet_hash[:created_at])
        if event.present?
          twitter_user.calendars.each do |calendar|
            user = calendar.user
            calendar_wrapper = GoogleCalendarWrapper.new(user.token, user.refresh_token)
            event_result = calendar_wrapper.insert_event(calendar.google_calendar_id, event.to_h)
            event.calendar_id = calendar.id
            event.google_event_id = event_result[:id]
            event.save!
          end
        end
      end
    end
  end
end
