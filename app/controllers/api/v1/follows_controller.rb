class Api::V1::FollowsController < Api::V1::BaseController
  def create
    ValidationUtils.validate_params(
      params: params,
      required_fields: %i[followed_user_id],
    )

    Follow::FollowOtherUserService.call(
      user_id: current_user.id,
      target_user_id: params[:followed_user_id],
    )

    render status: :created, json: {
      data: {
        success: true,
      },
    }
  end

  def destroy
    ValidationUtils.validate_params(
      params: params,
      required_fields: %i[followed_user_id],
    )

    Follow::UnfollowOtherUserService.call(
      user_id: current_user.id,
      target_user_id: params[:followed_user_id],
    )

    render status: :ok, json: {
      data: {
        success: true,
      },
    }
  end
end
