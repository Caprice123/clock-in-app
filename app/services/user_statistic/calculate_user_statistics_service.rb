class UserStatistic::CalculateUserStatisticsService < ApplicationService
  def initialize(sleep_record:)
    @sleep_record = sleep_record
  end

  def call
    user = @sleep_record.user
    return unless user

    ActiveRecord::Base.transaction do
      user_statistic = UserStatistic.find_or_create_by(user: user)
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
    user_statistic.total_sleep_records = user_statistic.total_sleep_duration.to_i + 1
  end

  private def calculate_completed_sleep_stats(user_statistic)
    user_statistic.total_awake_records = user_statistic.total_awake_records.to_i + 1
    user_statistic.total_sleep_duration = user_statistic.total_sleep_duration.to_i + @sleep_record.duration
    user_statistic.average_sleep_duration = user_statistic.total_sleep_duration.to_f / (user_statistic.total_sleep_records || 1)
  end
end
