class SleepRecord < ApplicationRecord
  include AASM

  belongs_to :user

  validates :duration, numericality: { greater_than: 0, allow_nil: true }
  after_create :refresh_statistics

  aasm requires_lock: true do
    state :sleeping, initial: true
    state :awake

    event :wake_up, after_commit: :refresh_statistics do
      before do
        set_wake_time
      end
      transitions from: :sleeping, to: :awake
    end
  end

  private def set_wake_time
    self.wake_time = Time.now.in_time_zone("Asia/Jakarta")
    self.duration = (wake_time - sleep_time).to_i
  end

  private def refresh_statistics
    CalculateUserStatisticsJob.perform_later(self)
  end
end
