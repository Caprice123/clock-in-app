describe Api::V1::FollowsController, type: :request do
  let!(:user) { create(:user) }
  let!(:target_user) { create(:user) }

  let(:url) { "/api/v1/follows" }
  let(:headers) do
    {
      "X-USERNAME": user.name,
    }
  end

  describe "#create" do
    let(:valid_params) do
      {
        followed_user_id: target_user.id,
      }
    end

    context "when following successfully" do
      it "returns success" do
        expect(Follow::FollowOtherUserService).to receive(:call)

        post(url, params: valid_params, headers: headers)

        expect(response).to have_http_status(:created)
        expect(response_body[:data]).to eq(
          {
            success: true,
          },
        )
      end
    end

    context "when validation fails" do
      it "raises validation error" do
        post(url, params: {}, headers: headers)

        expect(response).to have_http_status(:bad_request)
        expect(response_body[:error]).to eq(
          {
            code: "1000",
            title: "GENERAL ERROR",
            detail: "Parameter followed_user_id wajib diisi",
          },
        )
      end
    end

    context "when service raises UserError::NotFound" do
      it "raises the error" do
        expect(Follow::FollowOtherUserService).to receive(:call)
          .and_raise(UserError::NotFound)

        post(url, params: valid_params, headers: headers)

        expect(response).to have_http_status(:not_found)
        expect(response_body[:error]).to eq(
          {
            code: "USER1000",
            title: "USER NOT FOUND",
            detail: "User not found",
          },
        )
      end
    end
  end

  describe "#destroy" do
    let(:valid_params) do
      {
        followed_user_id: target_user.id,
      }
    end

    context "when unfollowing successfully" do
      before do
        create(:follow, user: user, followed_user: target_user)
        allow(Follow::UnfollowOtherUserService).to receive(:call).and_return(true)
        allow(ValidationUtils).to receive(:validate_params)
      end

      it "calls the unfollow service" do
        expect(Follow::UnfollowOtherUserService).to receive(:call).with(
          user_id: user.id,
          target_user_id: target_user.id.to_s,
        )

        delete("#{url}/#{target_user.id}", params: valid_params, headers: headers)
      end
    end

    context "when validation fails" do
      it "returns validation error" do
        delete("#{url}/#{target_user.id}", params: {}, headers: headers)

        expect(response).to have_http_status(:bad_request)
        expect(response_body[:error]).to eq(
          {
            code: "1000",
            title: "GENERAL ERROR",
            detail: "Parameter followed_user_id wajib diisi",
          },
        )
      end
    end

    context "when service raises UserError::NotFound" do
      before do
        allow(ValidationUtils).to receive(:validate_params)
        allow(Follow::UnfollowOtherUserService).to receive(:call)
          .and_raise(UserError::NotFound)
      end

      it "returns user not found error" do
        delete("#{url}/#{target_user.id}", params: valid_params, headers: headers)

        expect(response).to have_http_status(:not_found)
        expect(response_body[:error]).to eq(
          {
            code: "USER1000",
            title: "USER NOT FOUND",
            detail: "User not found",
          },
        )
      end
    end
  end
end
