module AuthenticationError
  class MissingUsername < HandledError
    default(
      title: "MISSING USERNAME",
      detail: "Username is missing",
      code: "1001",
      status: :unauthorized,
    )
  end

  class UserNotFound < HandledError
    default(
      title: "USER NOT FOUND",
      detail: "User not found",
      code: "1002",
      status: :unauthorized,
    )
  end
end
