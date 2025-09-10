describe UserStatistic::CalculateUserStatisticsService do
  let(:user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user) }

  subject { described_class.call(sleep_record: sleep_record) }

  before do
    travel_to Time.parse("2025-01-01 12:00:00+07:00")
  end

  describe "#call" do
    context "when sleep record is sleeping (ongoing)" do
      let(:sleep_record) { create(:sleep_record, user: user, aasm_state: "sleeping") }

      it "creates user statistic if not exists" do
        expect { subject }.to change { UserStatistic.count }.by(1)

        user_stat = user.user_statistic.reload
        expect(user_stat.user_id).to eq(user.id)
        expect(user_stat.last_calculated_at).to be_present
      end

      context "when user statistic already exists" do
        let!(:existing_stat) { create(:user_statistic, user: user, total_sleep_records: 5) }

        it "updates existing statistic" do
          expect { subject }.not_to change { UserStatistic.count }

          user_stat = user.user_statistic.reload
          expect(user_stat.last_calculated_at).to eq(Time.parse("2025-01-01 12:00:00+07:00"))
        end
      end
    end

    context "when sleep record is awake (completed)" do
      let(:sleep_record) do
        create(:sleep_record, user: user, aasm_state: "awake", duration: 480)
      end

      it "creates user statistic if not exists" do
        expect { subject }.to change { UserStatistic.count }.by(1)

        user_stat = user.user_statistic.reload
        expect(user_stat.user_id).to eq(user.id)
        expect(user_stat.last_calculated_at).to be_present
      end
    end

    context "when sleep record has no user" do
      before { allow(sleep_record).to receive(:user).and_return(nil) }

      it "returns early without creating statistics" do
        expect { subject }.not_to change { UserStatistic.count }
      end
    end
  end

  describe "#calculate_ongoing_sleep_stats" do
    let!(:user_stat) { create(:user_statistic, user: user, total_sleep_records: 3) }
    let(:service) { described_class.new(sleep_record: sleep_record) }

    it "increments total_sleep_records" do
      service.send(:calculate_ongoing_sleep_stats, user_stat)
      expect(user_stat.total_sleep_records).to eq(4)
    end
  end

  describe "#calculate_completed_sleep_stats" do
    let(:user_stat) do
      create(
        :user_statistic,
        user: user,
        total_awake_records: 2,
        total_sleep_duration: 600,
        total_sleep_records: 3,
      )
    end
    let(:sleep_record) { create(:sleep_record, user: user, aasm_state: "awake", duration: 480) }
    let(:service) { described_class.new(sleep_record: sleep_record) }

    it "updates completed sleep statistics" do
      service.send(:calculate_completed_sleep_stats, user_stat)

      expect(user_stat.total_awake_records).to eq(3)
      expect(user_stat.total_sleep_duration).to eq(1080)
      expect(user_stat.average_sleep_duration).to eq(360.0) # 1080 / 3
    end
  end
end
