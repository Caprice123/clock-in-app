FactoryBot.define do
  factory :follow do
    association :user
    association :followed_user, factory: :user
  end
end