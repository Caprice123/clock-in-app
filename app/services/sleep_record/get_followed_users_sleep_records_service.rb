class SleepRecord::GetFollowedUsersSleepRecordsService < ApplicationService
  def initialize(current_user:, page: 1, per_page: 10)
    @current_user = current_user
    @page = page.to_i
    @per_page = per_page.to_i
  end

  def call
    sleep_records = SleepRecord
      .joins(user: :follower_relationships)
      .where(follows: { user_id: @current_user.id }, aasm_state: :awake)
      .order(duration: :desc)
      .page(@page)
      .per(@per_page)
      .without_count

    [sleep_records, sleep_records.last_page?]
  end
end
