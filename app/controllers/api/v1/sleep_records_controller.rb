class Api::V1::SleepRecordsController < Api::V1::BaseController
  def create
    sleep_record = SleepRecord::ClockInService.call(current_user: current_user)

    render status: :created, json: {
      data: Api::V1::SleepRecordSerializer.new(sleep_record).serializable_hash[:data][:attributes],
    }
  end

  def wake_up
    sleep_record = SleepRecord::WakeUpService.call(current_user: current_user)

    render status: :ok, json: {
      data: Api::V1::SleepRecordSerializer.new(sleep_record).serializable_hash[:data][:attributes],
    }
  end
end
