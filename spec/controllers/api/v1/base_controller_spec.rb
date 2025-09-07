describe Api::V1::BaseController, type: :controller do
  controller(Api::V1::BaseController) do
    def index
      render json: { message: "success", current_user: current_user.name }
    end
  end

  let!(:user) { create(:user) }

  before do
    routes.draw { get "index" => "api/v1/base#index" }
  end

  describe "#validate_username" do
    subject { get :index }

    describe "authentication with X-USERNAME header" do
      context "when X-USERNAME header is present and user exists" do
        it "sets the current_user correctly" do
          @request.headers["X-USERNAME"] = user.name

          subject

          expect(response).to have_http_status(:ok)
          expect(response_body).to eq(
            {
              message: "success",
              current_user: user.name,
            },
          )
        end
      end

      context "when X-USERNAME header is missing" do
        it "raises AuthenticationError::MissingUsername" do
          @request.headers["X-USERNAME"] = nil

          subject

          expect(response).to have_http_status(:unauthorized)
          expect(response_body).to eq(
            {
              error: {
                title: "MISSING USERNAME",
                detail: "Username is missing",
                code: "1001",
              },
            },
          )
        end
      end

      context "when user with given username does not exist" do
        it "raises AuthenticationError::UserNotFound" do
          @request.headers["X-USERNAME"] = "nonexistent_user"

          subject

          expect(response).to have_http_status(:unauthorized)
          expect(response_body).to eq(
            {
              error: {
                title: "USER NOT FOUND",
                detail: "User not found",
                code: "1002",
              },
            },
          )
        end
      end
    end
  end
end
