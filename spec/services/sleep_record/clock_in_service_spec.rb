describe SleepRecord::ClockInService do
  let(:user) { create(:user) }

  subject { described_class.call(current_user: user) }

  context "when there is no existing sleep record" do
    it "creates a sleep record" do
      expect do
        subject
      end.to change { SleepRecord.count }.by(1)

      sleep_record = SleepRecord.last
      expect(sleep_record.user).to eq(user)
      expect(sleep_record.aasm_state).to eq("sleeping")
    end
  end

  context "when there is existing sleep record that is still pending" do
    it "raises error SleepRecordError::AlreadySleeping" do
      create(:sleep_record, user: user, aasm_state: "sleeping")

      expect { subject }.to raise_error(SleepRecordError::AlreadySleeping)
    end
  end
end
