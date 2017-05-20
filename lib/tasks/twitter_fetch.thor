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
      twitter.stream(user_ids) do |tweet_hash|
        twitter_user = TwitterUser.insert_or_update!(tweet_hash[:user])
        if twitter_user
          tweet = twitter_user.twitter_tweets.build(text: tweet_hash[:text])
          tweet.save!
        end

        if twitter_user.calendars.present?
          event = Event.parse_from_text(tweet_hash[:text])
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
end
