class UserStatistic::CalculateUserStatisticsService < ApplicationService
  def initialize(sleep_record:)
    @sleep_record = sleep_record
  end

  def call
    user = @sleep_record.user
    return unless user

    ActiveRecord::Base.transaction do
      user_statistic = UserStatistic
        .select(:id, :user_id, :total_sleep_records, :total_awake_records, :total_sleep_duration, :average_sleep_duration, :last_calculated_at)
        .find_or_create_by(user: user)
      if @sleep_record.sleeping?
        calculate_ongoing_sleep_stats(user_statistic)
      else
        calculate_completed_sleep_stats(user_statistic)
      end

      user_statistic.last_calculated_at = Time.now.in_time_zone("Asia/Jakarta")
      user_statistic.save!
    end
  end

  private def calculate_ongoing_sleep_stats(user_statistic)
    user_statistic.total_sleep_records = user_statistic.total_sleep_records.to_i + 1
  end

  private def calculate_completed_sleep_stats(user_statistic)
    user_statistic.total_awake_records = user_statistic.total_awake_records.to_i + 1
    user_statistic.total_sleep_duration = user_statistic.total_sleep_duration.to_i + @sleep_record.duration
    awake_count = user_statistic.total_awake_records.to_i
    user_statistic.average_sleep_duration = awake_count > 0 ? user_statistic.total_sleep_duration.to_f / awake_count : 0.0
  end
end
