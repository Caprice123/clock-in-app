FactoryBot.define do
  factory :sleep_record do
    association :user
    sleep_time { Time.now.in_time_zone("Asia/Jakarta") }
    status { "sleeping" }

    trait :sleeping do
      status { "sleeping" }
      wake_time { nil }
      duration { nil }
    end

    trait :awake do
      status { "awake" }
      wake_time { 2.hours.from_now }
      duration { 120 }
    end
  end
end
