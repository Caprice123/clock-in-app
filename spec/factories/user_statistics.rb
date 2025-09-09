FactoryBot.define do
  factory :user_statistic do
    association :user

    total_sleep_records { 0 }
    total_awake_records { 0 }
    total_sleep_duration { 0 }
    average_sleep_duration { 0.0 }
    last_calculated_at { Time.current }

    trait :with_sleep_data do
      total_sleep_records { 5 }
      total_awake_records { 3 }
      total_sleep_duration { 1440 } # 24 hours in minutes
      average_sleep_duration { 480.0 } # 8 hours average
    end

    trait :stale do
      last_calculated_at { 2.hours.ago }
    end

    trait :fresh do
      last_calculated_at { 30.minutes.ago }
    end
  end
end
