require 'thor/rails'
require './config/environment'

class Demo < Thor
  desc 'say [Name]', 'say task'
  def say(name)
    puts "Hello, #{name}!"
  end

  desc 'insert_and_share [Name]', 'test'
  def insert_and_share(name)
    user = User.find_by(email: 'hayakawa.890407@gmail.com')
    calendar = GoogleCalendarWrapper.new(user.token, user.refresh_token)
    insert_result = calendar.insert_calendar(name)
    calendar.share_to_email(insert_result[:id], 'discord.890407@gmail.com')
  end

  desc 'list', 'test'
  def list
    user = User.find_by(email: 'discord.890407@gmail.com')
    calendar = GoogleCalendarWrapper.new(user.token, user.refresh_token)
    calendar.calendar_lists do |calendar_item|
      p calendar_item
      calendar.events(calendar_item[:id]) do |event_item|
        p event_item
      end
    end
  end

  desc 'insert_calendar_and_event', 'test'
  def insert_calendar_and_event
    user = User.find_by(email: 'discord.890407@gmail.com')
    calendar = GoogleCalendarWrapper.new(user.token, user.refresh_token)
    insert_calendar_result = calendar.insert_calendar('test-h')
    p calendar.insert_event(insert_calendar_result[:id], {
      summary: 'test-h-summary',
      location: 'test-h-location',
      description: 'test-h-description',
      start: Time.zone.now,
      end: Time.zone.now + 1.hour,
    })
  end

  desc 'goo_test [text]', 'test'
  def goo_test(text)
    p ScheduleParser.parse(text)
  end

  desc 'goo_test [text]', 'test'
  def goo_test2(text)
    p ScheduleParser.parse(text, time_zone: 'Tokyo')
  end

  desc 'tweetstream', 'test'
  def tweetstream
    twitter = TwitterWrapper.new
    twitter.stream([149692927]) do |text|
      p text
    end
  end

  desc 'twitter user', 'test'
  def twitter_user
    twitter = TwitterWrapper.new
    p twitter.user(149692927)
  end

  desc 'twitter timeline', 'test'
  def twitter_timeline
    twitter = TwitterWrapper.new
    twitter.user_timeline(149692927, since_id: 836038367758319617) do |tweet|
      p tweet
    end
  end

  desc 'search twitter user', 'test'
  def twitter_user_search
    twitter = TwitterWrapper.new
    twitter.user_search('news_pia') do |user|
      p user
    end
  end

  desc 'search and create twitter user', 'test'
  def twitter_user_search_and_create
    twitter = TwitterWrapper.new
    twitter.user_search('news_pia') do |user|
      TwitterUser.insert_or_update!(user)
    end
  end

  desc 'search and create twitter user', 'test'
  def twitter_user_search_and_create2
    twitter = TwitterWrapper.new
    twitter.user_search('萬屋いっくん') do |user|
      TwitterUser.insert_or_update!(user)
    end
  end

  desc 'test mecab[text]', 'test'
  def test_mecab(text)
    word = MecabWrapper.parse(text)
    p word
    p word[0].wikipedia?
  end

  desc 'test tagger[text]', 'test'
  def test_tagger(text)
    TaggerWrapper.name_entity_extraction(text, time_zone: 'Asia/Tokyo') do |word|
      p word
    end
  end
end
