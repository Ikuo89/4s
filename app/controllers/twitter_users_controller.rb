class TwitterUsersController < ApplicationController
  before_action Login.new

  def search
    result = []
    q = params[:q]
    if q.present?
      twitter = TwitterWrapper.new
      twitter.user_search(q) do |user|
        result << user
      end
    end
    render json: result
  end

  def create
    id = params[:id]
    raise ActionController::BadRequest if id.blank?

    user_hash = twitter.user(id)
    twitter_user = TwitterUser.insert_or_update!(user_hash) if user_hash.present?

    calendar_wrapper = GoogleCalendarWrapper.new(user.token, user.refresh_token)
    if twitter_user.users.find_by(id: user.id).blank?
      calendar_result = calendar_wrapper.insert_calendar(twitter_user.screen_name)
      calendar = Calendar.insert_or_update!(calendar_result)
      twitter_user_calendar_relation = TwitterUserCalendarRelation.new(twitter_user_id: twitter_user.id, calendar_id: calendar.id)
      twitter_user_calendar_relation.save!
      twitter_user.reload

      user_calendars_relation = UserCalendarsRelation.new(user_id: user.id, calendar_id: calendar.id)
      user_calendars_relation.save!
    end
  end
end
