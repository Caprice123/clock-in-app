class SleepRecord::GetUserSleepRecordsService < ApplicationService
  def initialize(current_user:, page: 1, per_page: 10)
    @current_user = current_user
    @page = page.to_i
    @per_page = per_page.to_i
  end

  def call
    sleep_records = @current_user.sleep_records
      .order(created_at: :desc)
      .page(@page)
      .per(@per_page)
      .without_count

    [sleep_records, sleep_records.last_page?]
  end
end
