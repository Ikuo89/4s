class TwitterUsersController < ApplicationController
  before_action Login.new

  def search
    q = params[:q]
    raise ActionController::BadRequest if q.blank?

    result = []
    TwitterService.user_search(q) do |user|
      result << user.to_h.camelize_keys(:lower)
    end
    render json: result
  end

  def create
    id = params[:id].to_i
    raise ActionController::BadRequest if id.blank?

    twitter_user = begin
      TwitterService.create(id)
    rescue TwitterUserNotFoundError => e
      raise ActionController::BadRequest
    end

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

    render json: twitter_user.to_h
  end
end
