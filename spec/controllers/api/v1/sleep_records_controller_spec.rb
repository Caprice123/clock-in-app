describe Api::V1::SleepRecordsController, type: :request do
  let!(:user) { create(:user) }

  let(:url) { "/api/v1/sleep_records" }
  let(:headers) do
    {
      "X-USERNAME": user.name,
    }
  end

  before do
    travel_to Time.parse("2025-01-01 00:00:00+07:00")
  end

  describe "#create" do
    let!(:sleep_record) { create(:sleep_record, user: user) }

    context "when creating sleep record successfully" do
      it "calls the service and returns success" do
        expect(SleepRecord::ClockInService).to receive(:call).with(current_user: user).and_return(sleep_record)

        post(url, headers: headers)

        expect(response).to have_http_status(:created)
        expect(response_body[:data]).to eq(
          {
            id: sleep_record.id,
            user_id: user.id,
            aasm_state: "sleeping",
            sleep_time: "2025-01-01T00:00:00+07:00",
            wake_time: nil,
            duration: nil,
          },
        )
      end
    end

    context "when service raises SleepRecordError::AlreadySleeping" do
      before do
        allow(SleepRecord::ClockInService).to receive(:call)
          .and_raise(SleepRecordError::AlreadySleeping)
      end

      it "returns already sleeping error" do
        post(url, headers: headers)

        expect(response).to have_http_status(:conflict)
        expect(response_body[:error]).to eq(
          {
            code: "SLER1001",
            title: "ALREADY SLEEPING",
            detail: "User already has an active sleep record",
          },
        )
      end
    end
  end
end
