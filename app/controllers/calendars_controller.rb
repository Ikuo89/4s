class CalendarsController < ApplicationController
  before_action Login.new

  def index
    result = []
    user.calendars.each do |calendar|
      result << calendar.to_h.camelize_keys(:lower)
    end
    render json: result
  end
end
