describe Api::V1::UserStatisticsController, type: :request do
  let(:user) { create(:user) }
  let(:headers) do
    {
      "X-USERNAME": user.name,
    }
  end

  before do
    travel_to Time.parse("2025-01-01 12:00:00+07:00")
  end

  describe "#show" do
    let(:url) { "/api/v1/user_statistic" }

    context "when user has existing statistics" do
      let!(:user_statistic) do
        create(
          :user_statistic,
          user: user,
          total_sleep_records: 10,
          total_awake_records: 8,
          total_sleep_duration: 3840, # 64 hours in minutes
          average_sleep_duration: 480.0,
          last_calculated_at: Time.parse("2025-01-01 11:00:00+07:00"),
        )
      end

      it "returns existing user statistics" do
        get(url, headers: headers)

        expect(response).to have_http_status(:ok)
        expect(response_body[:data]).to eq(
          {
            user_id: user.id,
            total_sleep_records: 10,
            total_awake_records: 8,
            total_sleep_duration: 3840,
            average_sleep_duration: "480.0",
            last_calculated_at: "2025-01-01T11:00:00+07:00",
          },
        )
      end
    end

    context "when user has no statistics" do
      it "returns nil" do
        get(url, headers: headers)

        expect(response).to have_http_status(:ok)
        expect(response_body[:data]).to be_nil
      end
    end
  end
end
