class Follow::FollowOtherUserService < ApplicationService
  def initialize(user_id:, target_user_id:)
    @user_id = user_id
    @target_user_id = target_user_id
  end

  def call
    raise FollowError::UnallowedToSelfFollow if @user_id == @target_user_id

    target_user = User.find_by(id: @target_user_id)
    raise UserError::NotFound if target_user.blank?

    is_followed = Follow.exists?(user_id: @user_id, followed_user_id: @target_user_id)
    raise FollowError::AlreadyFollowed if is_followed

    Follow.create!(user_id: @user_id, followed_user_id: @target_user_id)
  end
end
