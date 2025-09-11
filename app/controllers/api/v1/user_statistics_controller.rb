class Api::V1::UserStatisticsController < Api::V1::BaseController
  def show
    statistic = current_user.user_statistic
    if statistic.blank?
      render status: :ok, json: {
        data: nil,
      }
      return
    end

    render status: :ok, json: {
      data: Api::V1::UserStatisticSerializer.new(statistic).serializable_hash[:data][:attributes],
    }
  end
end
