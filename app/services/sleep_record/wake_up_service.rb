class SleepRecord::WakeUpService < ApplicationService
  def initialize(current_user:)
    @current_user = current_user
  end

  def call
    sleep_record = SleepRecord.find_by(user: @current_user, aasm_state: :sleeping)
    raise SleepRecordError::NotSleeping unless sleep_record

    sleep_record.wake_up!
    sleep_record
  end
end
