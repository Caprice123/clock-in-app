class SleepRecord::GetFollowedUsersSleepRecordsService < ApplicationService
  def initialize(current_user:, per_page: 10, cursor: nil)
    @current_user = current_user
    @per_page = per_page.to_i
    @cursor = cursor
  end

  def call
    sleep_records = SleepRecord
      .select(:id, :user_id, :aasm_state, :sleep_time, :wake_time, :duration)
      .joins(user: :follower_relationships)
      .where(follows: { user_id: @current_user.id }, aasm_state: :awake)

    sleep_records = sleep_records.where("sleep_records.id < ?", @cursor) if @cursor.present?
    sleep_records = sleep_records.order(duration: :desc, id: :desc)
      .page(1)
      .per(@per_page)
      .without_count

    [sleep_records, sleep_records.last_page? || sleep_records.empty?]
  end
end
