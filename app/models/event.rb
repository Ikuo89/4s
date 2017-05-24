class Event < ApplicationRecord
  belongs_to :calendar
  default_scope ->{ where(deleted: 0) }

  def parsed_data
    JSON.parse(data, {:symbolize_names => true})
  end

  def summary
    parsed_data[:summary]
  end

  def description
    parsed_data[:description]
  end

  def color_id
    parsed_data[:color_id]
  end

  def location
    parsed_data[:location]
  end

  def date?
    if parsed_data[:start] =~ /\A\d+-\d+-\d+\Z/
      true
    else
      false
    end
  end

  def to_h
    {
      id: id,
      google_event_id: google_event_id,
      summary: summary,
      description: description,
      color_id: color_id,
      location: location,
      start: self.start,
      end: self.end,
      is_date: date?,
    }
  end

  class << self
    def insert_or_update!(calendar, event_item)
      event = self.find_by(calendar_id: calendar.id, google_event_id: event_item[:id], deleted: 0)
      if event.present?
        event.data = JSON.generate(event_item)
        event.start = event_item[:start]
        event.end = event_item[:end]
      else
        return nil if event_item[:start].blank? || event_item[:end].blank?
        event = self.new(
          calendar_id: calendar.id,
          google_event_id: event_item[:id],
          data: JSON.generate(event_item),
          start: event_item[:start],
          end: event_item[:end],
        )
      end

      event.save!
      event
    end

    def parse_from_text(text, time_zone: 'UTC', target_date: nil)
      schedule = ScheduleParser.parse(text, time_zone: time_zone, target_date: target_date)
      if schedule[:datetime].blank?
        return nil
      end

      event = self.new(
        data: JSON.generate({
          summary: schedule[:title],
          description: schedule[:description],
          location: schedule[:location],
        })
      )
      if schedule[:datetime].length == 1
        event.start = schedule[:datetime][0]
        event.end = schedule[:datetime][0] + 1.hour
      else
        event.start = schedule[:datetime][0]
        event.end = schedule[:datetime][1]
        if event.start > event.end
          event.start = schedule[:datetime][1]
          event.end = schedule[:datetime][0]
        end
      end

      event
    end
  end
end
