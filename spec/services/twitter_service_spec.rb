require 'rails_helper'

RSpec.describe TwitterService do
  let(:twitter_com_user_id) { 472144450 }
  let(:user) { create(:user) }
  let(:calendar) { create(:calendar) }

  before do
    @twitter_user = TwitterService.create(twitter_com_user_id)
  end

  it 'success watch_user_timeline' do
    expect(@twitter_user.twitter_tweets.count).to eq 0
    TwitterService.fetch_user_timeline
    expect(@twitter_user.twitter_tweets.count).to be > 0
  end

  it 'success watch_user_timeline with calendar' do
    TwitterUserCalendarRelation.create(twitter_user_id: @twitter_user.id, calendar_id: calendar.id)
    UserCalendarsRelation.create(user_id: user.id, calendar_id: calendar.id)
    allow_any_instance_of(GoogleCalendarWrapper).to receive(:insert_event).and_return({
      id: Faker::Number.between(10000000, 99999999),
      summary: Faker::Job.title,
      description: Faker::Job.title + ' description',
      time_zone: 'UTC',
      start: Faker::Time.between(1.days.from_now, 30.days.from_now),
      end: Faker::Time.between(1.days.from_now, 30.days.from_now),
    })
    allow(ScheduleParser).to receive(:parse).and_return({
      title: Faker::Job.title,
      description: Faker::Job.title + ' description',
      datetime: [Faker::Time.between(1.days.from_now, 30.days.from_now)],
    })

    expect(calendar.events.count).to eq 0
    TwitterService.fetch_user_timeline
    expect(calendar.events.count).to be > 0
  end
end
