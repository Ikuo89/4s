require 'thor/rails'
require './config/environment'

class CalendarSync < Thor
  desc 'fetch', 'calendar fetch'
  def fetch
    service = CalendarSyncService.new
    service.fetch_calendar
  end
end
