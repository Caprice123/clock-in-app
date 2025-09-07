class Follow::UnfollowOtherUserService < ApplicationService
  def initialize(user_id:, target_user_id:)
    @user_id = user_id
    @target_user_id = target_user_id
  end

  def call
    target_user = User.find_by(id: @target_user_id)
    raise UserError::NotFound if target_user.blank?

    follow_record = Follow.find_by(user_id: @user_id, followed_user_id: @target_user_id)
    raise FollowError::NotFollowed if follow_record.blank?

    follow_record.destroy!
  end
end
