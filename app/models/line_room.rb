class LineRoom < ApplicationRecord
  has_many :line_room_talks
  has_many :line_room_calendar_relations
  has_many :calendars, through: :line_room_calendar_relations
  has_many :users, through: :calendars
end
