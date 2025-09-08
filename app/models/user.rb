class User < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  # Following relationships
  has_many :follows, dependent: :destroy
  has_many :following, through: :follows, source: :followed_user

  has_many :follower_relationships, class_name: "Follow", foreign_key: "followed_user_id", dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :user

  # Sleep records
  has_many :sleep_records
end
