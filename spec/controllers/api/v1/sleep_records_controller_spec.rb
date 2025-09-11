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

  describe "#index" do
    context "when user has sleep records" do
      let!(:sleep_record1) do
        create(:sleep_record, user: user, aasm_state: "awake", duration: 480, created_at: 2.hours.ago)
      end
      let!(:sleep_record2) do
        create(:sleep_record, user: user, aasm_state: "sleeping", created_at: 1.hour.ago)
      end

      it "returns user's sleep records ordered by created_at descending" do
        get(url, headers: headers)

        expect(response).to have_http_status(:ok)
        expect(response_body[:data]).to eq(
          [
            {
              id: sleep_record2.id,
              user_id: user.id,
              aasm_state: "sleeping",
              sleep_time: "2025-01-01T00:00:00+07:00",
              wake_time: nil,
              duration: nil,
            },
            {
              id: sleep_record1.id,
              user_id: user.id,
              aasm_state: "awake",
              sleep_time: "2025-01-01T00:00:00+07:00",
              wake_time: nil,
              duration: 480,
            },
          ],
        )
        expect(response_body[:pagination]).to eq(
          {
            current_page: 1,
            per_page: 10,
            is_last_page: true,
          },
        )
      end
    end

    context "with pagination parameters" do
      let!(:sleep_records_data) do
        (1..15).map do |i|
          create(:sleep_record, user: user, aasm_state: "awake", duration: i * 60, created_at: i.hours.ago)
        end
      end

      it "respects cursor and per_page parameters" do
        get(url, params: { cursor: 1, per_page: 5 }, headers: headers)

        expect(response).to have_http_status(:ok)
        expect(response_body[:data].size).to eq(5)
        expect(response_body[:pagination]).to eq(
          {
            current_page: 1,
            per_page: 5,
            is_last_page: false,
          },
        )
      end
    end

    context "with invalid pagination parameters" do
      it "returns error for invalid cursor number" do
        get(url, params: { cursor: -1 }, headers: headers)

        expect(response).to have_http_status(:bad_request)
        expect(response_body[:error]).to eq(
          {
            code: "PAGR1001",
            title: "INVALID CURSOR",
            detail: "Cursor must be greater than or equal to 0",
          },
        )
      end

      it "returns error for invalid page size" do
        get(url, params: { per_page: 0 }, headers: headers)

        expect(response).to have_http_status(:bad_request)
        expect(response_body[:error]).to eq(
          {
            code: "PAGR1002",
            title: "INVALID PAGE SIZE",
            detail: "Page size must be greater than 0",
          },
        )
      end

      it "returns error for page size exceeding limit" do
        get(url, params: { per_page: 101 }, headers: headers)

        expect(response).to have_http_status(:bad_request)
        expect(response_body[:error]).to eq(
          {
            code: "PAGR1003",
            title: "PAGE SIZE EXCEED LIMIT",
            detail: "Page size exceeded the maximum allowed limit",
          },
        )
      end
    end
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

  describe "#followed_users" do
    let(:followed_users_url) { "#{url}/followed_users" }
    let(:followed_user1) { create(:user) }
    let(:followed_user2) { create(:user) }

    before do
      create(:follow, user: user, followed_user: followed_user1)
      create(:follow, user: user, followed_user: followed_user2)
    end

    context "when getting followed users sleep records successfully" do
      let!(:sleep_record1) do
        create(:sleep_record, user: followed_user1, aasm_state: "awake", wake_time: 6.hours.from_now, duration: 360)
      end
      let!(:sleep_record2) do
        create(:sleep_record, user: followed_user2, aasm_state: "awake", wake_time: 8.hours.from_now, duration: 480)
      end

      it "returns sleep records ordered by duration" do
        get(followed_users_url, headers: headers)

        expect(response).to have_http_status(:ok)
        expect(response_body[:data]).to eq(
          [
            {
              id: sleep_record2.id,
              user_id: followed_user2.id,
              aasm_state: "awake",
              sleep_time: "2025-01-01T00:00:00+07:00",
              wake_time: "2025-01-01T08:00:00+07:00",
              duration: 480,
            },
            {
              id: sleep_record1.id,
              user_id: followed_user1.id,
              aasm_state: "awake",
              sleep_time: "2025-01-01T00:00:00+07:00",
              wake_time: "2025-01-01T06:00:00+07:00",
              duration: 360,
            },
          ],
        )
        expect(response_body[:pagination]).to eq(
          {
            current_page: 1,
            per_page: 10,
            is_last_page: true,
          },
        )
      end
    end

    context "with pagination parameters" do
      let!(:sleep_records_data) do
        (1..15).map do |i|
          create(:sleep_record, user: followed_user1, aasm_state: "awake", duration: i * 60)
        end
      end

      it "respects cursor and per_page parameters" do
        get(followed_users_url, params: { cursor: 1, per_page: 5 }, headers: headers)

        expect(response).to have_http_status(:ok)
        expect(response_body[:data].size).to eq(5)
        expect(response_body[:pagination]).to eq(
          {
            current_page: 1,
            per_page: 5,
            is_last_page: false,
          },
        )
      end
    end

    context "with invalid pagination parameters" do
      it "returns error for invalid cursor number" do
        get(followed_users_url, params: { cursor: 0 }, headers: headers)

        expect(response).to have_http_status(:bad_request)
        expect(response_body[:error]).to eq(
          {
            code: "PAGR1001",
            title: "INVALID CURSOR",
            detail: "Cursor must be greater than or equal to 0",
          },
        )
      end

      it "returns error for invalid page size" do
        get(followed_users_url, params: { per_page: 0 }, headers: headers)

        expect(response).to have_http_status(:bad_request)
        expect(response_body[:error]).to eq(
          {
            code: "PAGR1002",
            title: "INVALID PAGE SIZE",
            detail: "Page size must be greater than 0",
          },
        )
      end

      it "returns error for page size exceeding limit" do
        get(followed_users_url, params: { per_page: 101 }, headers: headers)

        expect(response).to have_http_status(:bad_request)
        expect(response_body[:error]).to eq(
          {
            code: "PAGR1003",
            title: "PAGE SIZE EXCEED LIMIT",
            detail: "Page size exceeded the maximum allowed limit",
          },
        )
      end
    end

    context "when user has no followed users" do
      let(:lonely_user) { create(:user) }
      let(:lonely_headers) do
        {
          "X-USERNAME": lonely_user.name,
        }
      end

      it "returns empty results" do
        get(followed_users_url, headers: lonely_headers)

        expect(response).to have_http_status(:ok)
        expect(response_body[:data]).to be_empty
        expect(response_body[:pagination][:is_last_page]).to be true
      end
    end
  end
end
