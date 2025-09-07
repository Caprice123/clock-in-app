describe Follow::FollowOtherUserService do
  let!(:user) { create(:user) }
  let!(:target_user) { create(:user) }

  subject { described_class.call(user_id: user.id, target_user_id: target_user.id) }

  describe "#call" do
    context "when following a valid user successfully" do
      it "creates a follow relationship" do
        expect do
          subject
        end.to change(Follow, :count).by(1)

        follow = Follow.last
        expect(follow.user_id).to eq(user.id)
        expect(follow.followed_user_id).to eq(target_user.id)
      end
    end

    context "when target user does not exist" do
      it "raises UserError::NotFound" do
        expect do
          described_class.call(user_id: user.id, target_user_id: 99_999)
        end.to raise_error(UserError::NotFound)
      end
    end

    context "when user is already following the target user" do
      before do
        create(:follow, user: user, followed_user: target_user)
      end

      it "raises FollowError::AlreadyFollowed" do
        expect do
          subject
        end.to raise_error(FollowError::AlreadyFollowed)
      end
    end

    context "when trying to follow yourself" do
      it "raises FollowError::UnallowedToSelfFollow" do
        expect do
          described_class.call(user_id: user.id, target_user_id: user.id)
        end.to raise_error(FollowError::UnallowedToSelfFollow)
      end
    end
  end
end
