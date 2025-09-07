module UserError
  class NotFound < HandledError
    default(
      title: "USER NOT FOUND",
      detail: "User not found",
      code: "USER1000",
      status: :not_found,
    )
  end
end
