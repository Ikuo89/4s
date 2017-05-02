class LineRoomCalendarRelation < ApplicationRecord
  belongs_to :line_room
  belongs_to :calendar
end
