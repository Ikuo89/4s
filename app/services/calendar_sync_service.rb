class CalendarSyncService
  def initialize
  end

  def fetch_calendar
    User.find_each do |user|
      begin
        found_calendars = []
        calendar_wrapper = GoogleCalendarWrapper.new(user.token, user.refresh_token)
        calendar_wrapper.calendar_lists do |calendar_item|
          calendar = Calendar.insert_or_update!(calendar_item)
          relation = UserCalendarsRelation.find_or_initialize_by(user_id: user.id, calendar_id: calendar.id)
          relation.save!

          found_calendars << calendar

          found_events = []
          calendar_wrapper.events(calendar_item[:id]) do |event_item|
            event = Event.insert_or_update!(calendar, event_item)
            found_events << event if event.present?
          end

          calendar.events.where.not(id: found_events.map{|e| e.id }).each do |event|
            event.deleted = event.id
            event.save!
          end
        end

        user.calendars.where.not(id: found_calendars.map{|e| e.id }).each do |calendar|
          calendar.deleted = calendar.id
          calendar.save!
        end
      rescue => e
        Rails.logger.error e
      end
    end
  end
end
