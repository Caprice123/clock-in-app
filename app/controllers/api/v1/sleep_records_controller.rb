class Api::V1::SleepRecordsController < Api::V1::BaseController
  def index
    ValidationUtils.validate_params(
      params: params,
      required_fields: [],
      optional_fields: %i[page per_page],
    )

    page = params[:page] || 1
    raise PaginationError::InvalidPageNumber if page.to_i <= 0

    per_page = params[:per_page] || 10
    raise PaginationError::InvalidPageSize if per_page.to_i <= 0
    raise PaginationError::PageSizeExceedLimit if per_page.to_i > 100

    sleep_records, is_last_page = SleepRecord::GetUserSleepRecordsService.call(
      current_user: current_user,
      page: page.to_i,
      per_page: per_page.to_i,
    )

    render status: :ok, json: {
      data: Api::V1::SleepRecordSerializer.new(sleep_records).serializable_hash[:data].pluck(:attributes),
      pagination: {
        current_page: sleep_records.current_page,
        per_page: sleep_records.limit_value,
        is_last_page: is_last_page,
      },
    }
  end

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

  def followed_users
    ValidationUtils.validate_params(
      params: params,
      required_fields: [],
      optional_fields: %i[page per_page],
    )
    page = params[:page] || 1
    raise PaginationError::InvalidPageNumber if page.to_i <= 0

    per_page = params[:per_page] || 10
    raise PaginationError::InvalidPageSize if per_page.to_i <= 0
    raise PaginationError::PageSizeExceedLimit if per_page.to_i > 100

    sleep_records, is_last_page = SleepRecord::GetFollowedUsersSleepRecordsService.call(
      current_user: current_user,
      page: page.to_i,
      per_page: per_page.to_i,
    )

    render status: :ok, json: {
      data: Api::V1::SleepRecordSerializer.new(sleep_records).serializable_hash[:data].pluck(:attributes),
      pagination: {
        current_page: sleep_records.current_page,
        per_page: sleep_records.limit_value,
        is_last_page: is_last_page,
      },
    }
  end
end
