class CalculateUserStatisticsJob < ApplicationJob
  queue_as :default

  def perform(sleep_record)
    UserStatistic::CalculateUserStatisticsService.call(sleep_record: sleep_record)
  rescue StandardError => e
    user_id = sleep_record&.user_id || "unknown"
    Rails.logger.error "Failed to calculate statistics for user #{user_id}: #{e.message}"
    raise e
  end
end
