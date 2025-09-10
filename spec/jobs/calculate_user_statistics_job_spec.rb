describe CalculateUserStatisticsJob do
  let(:user) { create(:user) }
  let(:sleep_record) { create(:sleep_record, user: user) }

  subject { described_class.perform_now(sleep_record) }

  describe "#perform" do
    it "calls the CalculateUserStatisticsService" do
      expect(UserStatistic::CalculateUserStatisticsService).to receive(:call)
        .with(sleep_record: sleep_record)

      subject
    end

    context "when service raises StandardError" do
      before do
        allow(UserStatistic::CalculateUserStatisticsService).to receive(:call)
          .and_raise(StandardError.new("Database error"))
      end

      it "logs the error and re-raises it" do
        allow(Rails.logger).to receive(:error)

        expect { subject }.to raise_error(StandardError, "Database error")

        expect(Rails.logger).to have_received(:error)
          .with("Failed to calculate statistics for user #{user.id}: Database error")
      end
    end
  end
end
