class SleepRecord::GetUserSleepRecordsService < ApplicationService
  def initialize(current_user:, per_page: 10, cursor: nil)
    @current_user = current_user
    @per_page = per_page.to_i
    @cursor = cursor
  end

  def call
    sleep_records = @current_user.sleep_records
      .select(:id, :user_id, :aasm_state, :sleep_time, :wake_time, :duration, :created_at)

    sleep_records = sleep_records.where("id < ?", @cursor) if @cursor.present?
    sleep_records = sleep_records.order(created_at: :desc, id: :desc)
      .page(1)
      .per(@per_page)
      .without_count

    [sleep_records, sleep_records.last_page? || sleep_records.empty?]
  end
end
