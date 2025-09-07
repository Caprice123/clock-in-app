describe Follow::UnfollowOtherUserService do
  let!(:user) { create(:user) }
  let!(:target_user) { create(:user) }

  subject { described_class.call(user_id: user.id, target_user_id: target_user.id) }

  describe "#call" do
    context "when unfollowing a followed user successfully" do
      before do
        create(:follow, user: user, followed_user: target_user)
      end

      it "removes the specific follow relationship" do
        subject

        expect(Follow.exists?(user_id: user.id, followed_user_id: target_user.id)).to be false
      end
    end

    context "when target user does not exist" do
      it "raises UserError::NotFound" do
        expect do
          described_class.call(user_id: user.id, target_user_id: 99_999)
        end.to raise_error(UserError::NotFound)
      end
    end

    context "when user is not following the target user" do
      it "raises FollowError::NotFollowed" do
        expect do
          subject
        end.to raise_error(FollowError::NotFollowed)
      end
    end
  end
end
