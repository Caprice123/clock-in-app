class Api::V1::SleepRecordsController < Api::V1::BaseController
  def create
    sleep_record = SleepRecord::CreateSleepRecordService.call(user_id: current_user.id)

    render status: :created, json: {
      data: Admin::V1::BannerSerializer.new(sleep_record).serializable_hash[:data].pluck(:attributes),
    }
  end
end
