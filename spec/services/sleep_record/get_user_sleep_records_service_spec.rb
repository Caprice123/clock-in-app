describe SleepRecord::GetUserSleepRecordsService do
  let(:current_user) { create(:user) }
  let(:other_user) { create(:user) }

  subject { described_class.call(current_user: current_user, page: 1, per_page: 10) }

  before do
    travel_to Time.parse("2025-01-01 12:00:00+07:00")
  end

  context "when user has sleep records" do
    let!(:sleep_record1) do
      create(:sleep_record, user: current_user, aasm_state: "sleeping", created_at: 1.day.ago)
    end
    let!(:sleep_record2) do
      create(:sleep_record, user: current_user, aasm_state: "awake", duration: 480, created_at: 2.hours.ago)
    end
    let!(:sleep_record3) do
      create(:sleep_record, user: current_user, aasm_state: "awake", duration: 360, created_at: 1.hour.ago)
    end

    it "returns sleep records ordered by created_at descending" do
      sleep_records, is_last_page = subject

      expect(sleep_records.size).to eq(3)
      expect(sleep_records.map(&:id)).to eq([sleep_record3.id, sleep_record2.id, sleep_record1.id])
      expect(sleep_records.map(&:created_at).map(&:to_i)).to eq(
        [
          1.hour.ago.to_i,
          2.hours.ago.to_i,
          1.day.ago.to_i,
        ],
      )
      expect(is_last_page).to be true
    end

    it "includes both sleeping and awake records" do
      sleep_records, _is_last_page = subject

      states = sleep_records.map(&:aasm_state)
      expect(states).to include("sleeping")
      expect(states).to include("awake")
    end
  end

  context "when other user has sleep records" do
    let!(:other_user_record) do
      create(:sleep_record, user: other_user, aasm_state: "awake", duration: 480)
    end

    it "does not include other users' records" do
      sleep_records, _is_last_page = subject

      expect(sleep_records).to be_empty
    end
  end

  context "with pagination" do
    let!(:sleep_records_data) do
      # Create 15 sleep records with different created_at times
      (1..15).map do |i|
        create(:sleep_record, user: current_user, aasm_state: "awake", duration: i * 60, created_at: i.hours.ago)
      end
    end

    it "respects page and per_page parameters" do
      sleep_records, is_last_page = described_class.call(
        current_user: current_user,
        page: 1,
        per_page: 5,
      )

      expect(sleep_records.size).to eq(5)
      # Should get the 5 most recent records (1, 2, 3, 4, 5 hours ago)
      expected_times = (1..5).map { |i| i.hours.ago.to_i }
      actual_times = sleep_records.map { |r| r.created_at.to_i }
      expect(actual_times).to eq(expected_times)
      expect(is_last_page).to be false
    end

    it "returns correct is_last_page for last page" do
      sleep_records, is_last_page = described_class.call(
        current_user: current_user,
        page: 3,
        per_page: 5,
      )

      expect(sleep_records.size).to eq(5)
      expect(is_last_page).to be true
    end

    it "returns empty results for page beyond available data" do
      sleep_records, is_last_page = described_class.call(
        current_user: current_user,
        page: 10,
        per_page: 5,
      )

      expect(sleep_records).to be_empty
      expect(is_last_page).to be true
    end
  end

  context "when user has no sleep records" do
    it "returns empty results" do
      sleep_records, is_last_page = subject

      expect(sleep_records).to be_empty
      expect(is_last_page).to be true
    end
  end

  context "with edge case pagination parameters" do
    let!(:single_record) { create(:sleep_record, user: current_user) }

    it "handles page 1 with per_page 1" do
      sleep_records, is_last_page = described_class.call(
        current_user: current_user,
        page: 1,
        per_page: 1,
      )

      expect(sleep_records.size).to eq(1)
      expect(sleep_records.first).to eq(single_record)
      expect(is_last_page).to be true
    end

    it "handles large per_page value" do
      sleep_records, is_last_page = described_class.call(
        current_user: current_user,
        page: 1,
        per_page: 100,
      )

      expect(sleep_records.size).to eq(1)
      expect(is_last_page).to be true
    end
  end
end
