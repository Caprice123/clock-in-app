class User < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  
  # Following relationships
  has_many :active_follows, class_name: 'Follow',
                            foreign_key: 'user_id',
                            dependent: :destroy
  has_many :passive_follows, class_name: 'Follow',
                             foreign_key: 'followed_user_id',
                             dependent: :destroy
                             
  # Users that this user is following
  has_many :following, through: :active_follows, source: :followed_user
  
  # Users that are following this user
  has_many :followers, through: :passive_follows, source: :user
  
  # Follow a user
  def follow(other_user)
    following << other_user unless self == other_user
  end
  
  # Unfollow a user
  def unfollow(other_user)
    following.delete(other_user)
  end
  
  # Check if following a user
  def following?(other_user)
    following.include?(other_user)
  end
end