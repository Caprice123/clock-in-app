module SleepRecordError
  class AlreadySleeping < HandledError
    def initialize
      super(
        code: "SLER1001",
        title: "ALREADY SLEEPING",
        detail: "User already has an active sleep record",
        status: :conflict
      )
    end
  end

  class NotSleeping < HandledError
    def initialize
      super(
        code: "SLER1002",
        title: "NOT SLEEPING",
        detail: "User doesn't have an active sleep record to wake up from",
        status: :bad_request,
      )
    end
  end
end
