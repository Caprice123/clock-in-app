module PaginationError
  class InvalidPageNumber < HandledError
    def initialize
      super(
        title: "INVALID PAGE NUMBER",
        detail: "Page number must be greater than 0",
        code: "PAGR1001",
        status: :bad_request,
      )
    end
  end

  class InvalidPageSize < HandledError
    def initialize
      super(
        title: "INVALID PAGE SIZE",
        detail: "Page size must be greater than 0",
        code: "PAGR1002",
        status: :bad_request,
      )
    end
  end

  class PageSizeExceedLimit < HandledError
    def initialize
      super(
        title: "PAGE SIZE EXCEED LIMIT",
        detail: "Page size exceeded the maximum allowed limit",
        code: "PAGR1003",
        status: :bad_request,
      )
    end
  end
end
