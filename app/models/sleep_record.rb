class SleepRecord < ApplicationRecord
  include AASM

  belongs_to :user

  validates :sleep_time, presence: true
  validates :duration, numericality: { greater_than: 0, allow_nil: true }

  aasm requires_lock: true do
    state :sleeping, initial: true
    state :awake

    event :wake_up do
      transitions from: :sleeping, to: :awake

      before do
        self.wake_time = Time.now.in_time_zone("Asia/Jakarta")
        self.duration = calculate_duration
      end
    end
  end

  private def calculate_duration
    (wake_time - sleep_time) / 60
  end
end
