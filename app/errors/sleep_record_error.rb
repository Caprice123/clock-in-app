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
end
