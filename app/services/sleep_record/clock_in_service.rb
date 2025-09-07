class SleepRecord::ClockInService < ApplicationService
  def initialize(current_user:)
    @current_user = current_user
  end

  def call
    existing_sleep = SleepRecord.exists?(user: @current_user, aasm_state: :sleeping)
    raise SleepRecordError::AlreadySleeping if existing_sleep

    SleepRecord.create!(user: @current_user, sleep_time: Time.now.in_time_zone("Asia/Jakarta"))
  end
end
