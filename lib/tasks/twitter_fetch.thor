require 'thor/rails'
require './config/environment'

class TwitterFetch < Thor
  desc 'watch', 'start watch process'
  def watch
    BatchSerializer.run do
      user_ids = []
      TwitterUser.all.each do |user|
        user_ids << user.twitter_com_user_id
      end

      twitter = TwitterWrapper.new
      twitter.stream(user_ids) do |tweet|
        user = TwitterUser.insert_or_update!(tweet[:user])
        if user
          tweet = user.twitter_tweets.build(text: tweet[:text])
          tweet.save!
        end
      end
    end
  end
end
