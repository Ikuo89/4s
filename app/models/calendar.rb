class Calendar < ApplicationRecord
  has_one :line_room_calendar_relation
  has_one :line_room, through: :line_room_calendar_relations
  has_one :user_calendars_relation
  has_one :user, through: :user_calendars_relation
  has_many :events
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

  def background_color
    parsed_data[:background_color]
  end

  def foreground_color
    parsed_data[:foreground_color]
  end

  def access_role
    parsed_data[:access_role]
  end

  def selected
    parsed_data[:selected]
  end

  def to_h
    {
      id: id,
      google_calendar_id: google_calendar_id,
      summary: summary,
      description: description,
      color_id: color_id,
      background_color: background_color,
      foreground_color: foreground_color,
      access_role: access_role,
      selected: selected,
    }
  end

  class << self
    def insert_or_update!(calendar_item)
      calendar = self.find_by(google_calendar_id: calendar_item[:id], deleted: 0)
      if calendar.present?
        calendar.data = JSON.generate(calendar_item)
      else
        calendar = self.new(
          google_calendar_id: calendar_item[:id],
          data: JSON.generate(calendar_item),
        )
      end

      calendar.save!
      calendar
    end
  end
end
