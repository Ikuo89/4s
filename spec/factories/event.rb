FactoryGirl.define do
  factory :event do
    association :calendar
    google_event_id Faker::Number.between(10000000, 99999999)
    start Faker::Date.between(1.days.from_now, 30.days.from_now)
    self.end Faker::Date.between(1.days.from_now, 30.days.from_now)
    data JSON.generate({ summary: Gimei.name.kanji })
  end
end
