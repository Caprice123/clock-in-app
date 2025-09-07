class Api::V1::SleepRecordSerializer < BaseSerializer
  attributes :id, :user_id, :aasm_state, :duration

  attribute :sleep_time do |object|
    object.sleep_time.in_time_zone("Asia/Jakarta").iso8601
  end

  attribute :wake_up do |object|
    object.wake_up&.in_time_zone("Asia/Jakarta")&.iso8601
  end
end
