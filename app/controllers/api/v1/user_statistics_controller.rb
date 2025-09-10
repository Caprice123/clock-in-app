class Api::V1::UserStatisticsController < Api::V1::BaseController
  def show
    statistic = current_user.user_statistic&.select(:id, :user_id, :total_sleep_records, :total_awake_records, :total_sleep_duration, :average_sleep_duration, :last_calculated_at)

    render status: :ok, json: {
      data: Api::V1::UserStatisticSerializer.new(statistic).serializable_hash[:data][:attributes],
    }
  end
end
