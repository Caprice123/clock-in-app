class Api::V1::UserStatisticSerializer < BaseSerializer
  attributes :user_id,
    :total_sleep_records,
    :total_awake_records,
    :total_sleep_duration,
    :average_sleep_duration

  attribute :last_calculated_at do |object|
    object.last_calculated_at.in_time_zone("Asia/Jakarta").iso8601
  end
end
