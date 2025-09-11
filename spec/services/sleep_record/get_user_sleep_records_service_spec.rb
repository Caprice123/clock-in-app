describe SleepRecord::GetUserSleepRecordsService do
  let(:current_user) { create(:user) }
  let(:other_user) { create(:user) }

  subject { described_class.call(current_user: current_user, per_page: 10) }

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

  context "with cursor pagination" do
    let!(:sleep_records_data) do
      (1..15).map do |i|
        create(:sleep_record, id: i, user: current_user, aasm_state: "awake", duration: i * 60)
      end
    end

    it "respects per_page parameter without cursor" do
      sleep_records, is_last_page = described_class.call(
        current_user: current_user,
        per_page: 5,
      )

      expect(sleep_records.size).to eq(5)
      expect(sleep_records.map(&:id)).to eq(15.downto(11).to_a)
      expect(is_last_page).to be false
    end

    it "respects cursor parameter for pagination" do
      # First get initial page
      first_page, first_is_last = described_class.call(
        current_user: current_user,
        per_page: 5,
      )

      expect(first_is_last).to be false
      cursor = first_page.last.id

      # Then get next page using cursor
      second_page, second_is_last = described_class.call(
        current_user: current_user,
        per_page: 5,
        cursor: cursor,
      )

      expect(second_page.size).to eq(5)
      expect(second_is_last).to be false

      # Verify no overlap between pages
      first_ids = first_page.map(&:id)
      second_ids = second_page.map(&:id)
      expect(first_ids & second_ids).to be_empty

      # Verify cursor worked
      expect(second_ids).to eq(10.downto(6).to_a)
    end

    it "returns is_last_page true when reaching end" do
      sleep_records, is_last_page = described_class.call(
        current_user: current_user,
        per_page: 20, # More than total records (15)
      )

      expect(sleep_records.size).to eq(15)
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

    it "handles per_page 1" do
      sleep_records, is_last_page = described_class.call(
        current_user: current_user,
        per_page: 1,
      )

      expect(sleep_records.size).to eq(1)
      expect(sleep_records.first).to eq(single_record)
      expect(is_last_page).to be true
    end

    it "handles large per_page value" do
      sleep_records, is_last_page = described_class.call(
        current_user: current_user,
        per_page: 100,
      )

      expect(sleep_records.size).to eq(1)
      expect(is_last_page).to be true
    end
  end
end
