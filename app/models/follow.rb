class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :followed_user, class_name: "User"

  validates :user_id, presence: true
  validates :followed_user_id, presence: true
  validates :user_id, uniqueness: { scope: :followed_user_id }

  validate :cannot_follow_self

  private def cannot_follow_self
    errors.add(:followed_user_id, "cannot follow yourself") if user_id == followed_user_id
  end
end
