describe SleepRecord::GetFollowedUsersSleepRecordsService do
  let(:current_user) { create(:user) }
  let(:followed_user1) { create(:user) }
  let(:followed_user2) { create(:user) }
  let(:unfollowed_user) { create(:user) }

  subject { described_class.call(current_user: current_user, per_page: 10) }

  before do
    travel_to Time.parse("2025-01-01 12:00:00+07:00")

    # Set up follow relationships
    create(:follow, user: current_user, followed_user: followed_user1)
    create(:follow, user: current_user, followed_user: followed_user2)
  end

  context "when followed users have awake sleep records" do
    before do
      @sleep_record1 = create(:sleep_record, user: followed_user1, aasm_state: "awake", duration: 480) # 8 hours
      @sleep_record2 = create(:sleep_record, user: followed_user2, aasm_state: "awake", duration: 360) # 6 hours
      @sleep_record3 = create(:sleep_record, user: followed_user1, aasm_state: "awake", duration: 600) # 10 hours
    end

    it "returns sleep records ordered by duration descending" do
      sleep_records, is_last_page = subject

      expect(sleep_records.size).to eq(3)
      expect(sleep_records.map(&:duration)).to eq([600, 480, 360])
      expect(is_last_page).to be true
    end

    it "returns only awake records from followed users" do
      sleep_records, _is_last_page = subject

      expect(sleep_records.all? { |record| record.aasm_state == "awake" }).to be true
      expect(sleep_records.map(&:user)).to all(be_in([followed_user1, followed_user2]))
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

  context "with cursor pagination" do
    let!(:sleep_records_data) do
      # Create 15 sleep records with different durations and specific IDs
      (1..15).map do |i|
        create(:sleep_record, id: i, user: followed_user1, aasm_state: "awake", duration: i * 60)
      end
    end

    it "respects per_page parameter without cursor" do
      sleep_records, is_last_page = described_class.call(
        current_user: current_user,
        per_page: 5,
      )

      expect(sleep_records.size).to eq(5)
      # Should get records ordered by duration DESC, id DESC
      expected_durations = [900, 840, 780, 720, 660] # Highest durations first
      expect(sleep_records.map(&:duration)).to eq(expected_durations)
      expect(is_last_page).to be false
    end

    it "respects cursor parameter for pagination" do
      # First get initial page
      first_page, first_is_last = described_class.call(
        current_user: current_user,
        per_page: 5,
      )

      expect(first_is_last).to be false
      cursor = first_page.last.id # Use last record's ID as cursor

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
      # Get records near the end
      sleep_records, is_last_page = described_class.call(
        current_user: current_user,
        per_page: 20, # More than total records (15)
      )

      expect(sleep_records.size).to eq(15)
      expect(is_last_page).to be true
    end
  end

  context "when user follows no one" do
    let(:lonely_user) { create(:user) }

    subject { described_class.call(current_user: lonely_user, per_page: 10) }

    it "returns empty results" do
      sleep_records, is_last_page = subject

      expect(sleep_records).to be_empty
      expect(is_last_page).to be true
    end
  end
end
