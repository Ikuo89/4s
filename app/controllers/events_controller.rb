class EventsController < ApplicationController
  before_action Login.new

  def index
    result = []
    user.calendars.find_by(id: params[:calendar_id])&.events.find_each do |event|
      result << event.to_h.camelize_keys(:lower)
    end
    render json: result
  end
end
