class User < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  # Following relationships
  has_many :active_follows, class_name: "Follow",
    foreign_key: "user_id",
    dependent: :destroy
  has_many :passive_follows, class_name: "Follow",
    foreign_key: "followed_user_id",
    dependent: :destroy

  # Users that this user is following
  has_many :following, through: :active_follows, source: :followed_user

  # Users that are following this user
  has_many :followers, through: :passive_follows, source: :user

  # Sleep records
  has_many :sleep_records
end
