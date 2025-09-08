describe SleepRecord::GetFollowedUsersSleepRecordsService do
  let(:current_user) { create(:user) }
  let(:followed_user1) { create(:user) }
  let(:followed_user2) { create(:user) }
  let(:unfollowed_user) { create(:user) }

  subject { described_class.call(current_user: current_user, page: 1, per_page: 10) }

  before do
    travel_to Time.parse("2025-01-01 12:00:00+07:00")

    # Set up follow relationships
    create(:follow, user: current_user, followed_user: followed_user1)
    create(:follow, user: current_user, followed_user: followed_user2)
  end

  context "when followed users have awake sleep records" do
    let!(:sleep_record1) do
      create(:sleep_record, user: followed_user1, aasm_state: "awake", duration: 480) # 8 hours
    end
    let!(:sleep_record2) do
      create(:sleep_record, user: followed_user2, aasm_state: "awake", duration: 360) # 6 hours
    end
    let!(:sleep_record3) do
      create(:sleep_record, user: followed_user1, aasm_state: "awake", duration: 600) # 10 hours
    end

    it "returns sleep records ordered by duration descending" do
      sleep_records, is_last_page = subject

      expect(sleep_records.size).to eq(3)
      expect(sleep_records.map(&:duration)).to eq([600, 480, 360])
      expect(sleep_records.map(&:user)).to eq([followed_user1, followed_user1, followed_user2])
      expect(is_last_page).to be true
    end

    it "returns Kaminari paginated results" do
      sleep_records, _is_last_page = subject

      expect(sleep_records).to respond_to(:current_page)
      expect(sleep_records).to respond_to(:limit_value)
      expect(sleep_records).to respond_to(:last_page?)
      expect(sleep_records.current_page).to eq(1)
      expect(sleep_records.limit_value).to eq(10)
    end
  end

  context "when followed users have sleeping records" do
    let!(:sleeping_record) do
      create(:sleep_record, user: followed_user1, aasm_state: "sleeping")
    end

    it "does not include sleeping records" do
      sleep_records, _is_last_page = subject

      expect(sleep_records).to be_empty
    end
  end

  context "when unfollowed user has sleep records" do
    let!(:unfollowed_sleep_record) do
      create(:sleep_record, user: unfollowed_user, aasm_state: "awake", duration: 480)
    end

    it "does not include unfollowed users' records" do
      sleep_records, _is_last_page = subject

      expect(sleep_records).to be_empty
    end
  end

  context "with pagination" do
    let!(:sleep_records_data) do
      # Create 15 sleep records with different durations
      (1..15).map do |i|
        create(:sleep_record, user: followed_user1, aasm_state: "awake", duration: i * 60)
      end
    end

    it "respects page and per_page parameters" do
      sleep_records, is_last_page = described_class.call(
        current_user: current_user,
        page: 1,
        per_page: 5,
      )

      expect(sleep_records.size).to eq(5)
      expect(sleep_records.map(&:duration)).to eq([900, 840, 780, 720, 660]) # Highest durations first
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

  context "when user follows no one" do
    let(:lonely_user) { create(:user) }

    subject { described_class.call(current_user: lonely_user, page: 1, per_page: 10) }

    it "returns empty results" do
      sleep_records, is_last_page = subject

      expect(sleep_records).to be_empty
      expect(is_last_page).to be true
    end
  end
end
