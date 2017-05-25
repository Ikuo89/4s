FactoryGirl.define do
  factory :calendar do
    google_calendar_id Faker::Number.between(10000000, 99999999)
    data JSON.generate({ summary: Gimei.name.kanji })
  end
end
