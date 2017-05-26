require 'thor/rails'
require './config/environment'

class TwitterFetch < Thor
  desc 'watch', 'start watch process'
  def watch
    BatchSerializer.run do
      TwitterService.watch_user_timeline
    end
  end

  desc 'fetch', 'start fetch'
  def fetch
    TwitterService.fetch_user_timeline
  end

  desc 'search', 'start fetch'
  def collect_data
    start_date = Date.parse('2017-1-1')

    twitter = TwitterWrapper.new
    tweet = TwitterTweet.order(twitter_com_tweet_id: :asc).first
    options = {}
    options[:max_id] = tweet.twitter_com_tweet_id if tweet.present?

    (start_date..Date.today).each do |target_date|
      twitter.search('"00〜"', options) do |tweet_hash|
        tweet = TwitterTweet.find_by(twitter_com_tweet_id: tweet_hash[:id])
        next if tweet.present?

        twitter_user = TwitterUser.insert_or_update!(tweet_hash[:user])
        tweet = twitter_user.twitter_tweets.build(
          twitter_com_tweet_id: tweet_hash[:id],
          text: tweet_hash[:text],
          created_at: tweet_hash[:created_at],
        )
        tweet.save!
      end
    end
  end
end
