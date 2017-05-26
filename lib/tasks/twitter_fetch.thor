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
    twitter = TwitterWrapper.new
    (Date.parse('2017-5-1')..Date.today).each do |target_date|
      twitter.search('"00〜"', since: target_date.strftime('%Y-%m-%d'), until: (target_date + 1.day).strftime('%Y-%m-%d')) do |tweet_hash|
        tweet = TwitterTweet.find_by(twitter_com_tweet_id: tweet_hash[:id])
        next if tweet.present?

        twitter_user = TwitterUser.insert_or_update!(tweet_hash[:user])
        tweet = twitter_user.twitter_tweets.build(
          twitter_com_tweet_id: tweet_hash[:id],
          text: tweet_hash[:text],
        )
        tweet.save!
      end
    end
  end
end
