module FollowError
  class UnallowedToSelfFollow < HandledError
    default(
      title: "UNALLOWED TO SELF FOLLOW",
      detail: "User cannot follow themselves",
      code: "FOER1001",
      status: :bad_request,
    )
  end

  class AlreadyFollowed < HandledError
    default(
      title: "ALREADY FOLLOWED",
      detail: "User already followed",
      code: "FOER1002",
      status: :conflict,
    )
  end

  class NotFollowed < HandledError
    default(
      title: "NOT FOLLOWED",
      detail: "User is not followed",
      code: "FOER1003",
      status: :not_found,
    )
  end
end
