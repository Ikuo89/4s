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
end
