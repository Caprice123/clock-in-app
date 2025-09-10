describe SleepRecord::WakeUpService do
  let(:user) { create(:user) }

  subject { described_class.call(current_user: user) }

  before do
    travel_to Time.parse("2025-01-01 08:00:00+07:00")
  end

  context "when user has an active sleep record" do
    let!(:sleep_record) do
      create(:sleep_record, user: user, aasm_state: "sleeping", sleep_time: Time.parse("2025-01-01 00:00:00+07:00"))
    end

    it "wakes up the sleep record and calculates duration" do
      result = subject

      expect(result).to eq(sleep_record)
      expect(result.aasm_state).to eq("awake")
      expect(result.wake_time).to eq(Time.parse("2025-01-01 08:00:00+07:00"))
      expect(result.duration).to eq(8 * 60 * 60) # 8 hours in seconds
    end

    it "transitions from sleeping to awake state" do
      expect { subject }.to change { sleep_record.reload.aasm_state }.from("sleeping").to("awake")
    end
  end

  context "when user has no active sleep record" do
    it "raises SleepRecordError::NotSleeping" do
      expect { subject }.to raise_error(SleepRecordError::NotSleeping)
    end
  end

  context "when user has already woken up" do
    let!(:sleep_record) do
      create(:sleep_record, user: user, aasm_state: "awake")
    end

    it "raises SleepRecordError::NotSleeping" do
      expect { subject }.to raise_error(SleepRecordError::NotSleeping)
    end
  end
end
