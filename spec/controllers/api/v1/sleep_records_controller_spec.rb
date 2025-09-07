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

  describe "#wake_up" do
    let!(:sleep_record) { create(:sleep_record, user: user, aasm_state: :sleeping) }
    let(:wake_up_url) { "#{url}/#{sleep_record.id}/wake_up" }

    context "when waking up successfully" do
      before do
        sleep_record.awake!
      end

      it "calls the WakeUpService and returns success" do
        expect(SleepRecord::WakeUpService).to receive(:call).with(current_user: user).and_return(awake_sleep_record)

        patch(wake_up_url, headers: headers)

        expect(response).to have_http_status(:ok)
        expect(response_body[:data]).to eq(
          {
            id: sleep_record.id,
            user_id: user.id,
            aasm_state: "awake",
            sleep_time: "2025-01-01T00:00:00+07:00",
            wake_time: "2025-01-01T08:00:00+07:00",
            duration: 480,
          },
        )
      end
    end

    context "when service raises SleepRecordError::NotSleeping" do
      before do
        allow(SleepRecord::WakeUpService).to receive(:call)
          .and_raise(SleepRecordError::NotSleeping)
      end

      it "returns not sleeping error" do
        patch(wake_up_url, headers: headers)

        expect(response).to have_http_status(:bad_request)
        expect(response_body[:error]).to eq(
          {
            code: "SLER1002",
            title: "NOT SLEEPING",
            detail: "User doesn't have an active sleep record to wake up from",
          },
        )
      end
    end
  end
end
