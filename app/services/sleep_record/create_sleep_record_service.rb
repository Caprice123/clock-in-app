class SleepRecord::CreateSleepRecordService < ApplicationService
  def initialize(current_user:)
    @current_user = current_user
  end

  def call
    existing_sleep = SleepRecord.exists?(user: @current_user, aasm_state: :sleeping)
    raise SleepRecordError::AlreadySleeping if existing_sleep

    SleepRecord.create!(user: @current_user)
  end
end
