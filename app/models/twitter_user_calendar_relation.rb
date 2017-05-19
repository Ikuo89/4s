class TwitterUserCalendarRelation < ApplicationRecord
  belongs_to :twitter_user
  belongs_to :calendar
end
