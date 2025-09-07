class ApplicationController < ActionController::Base
  rescue_from StandardError, with: :handle_unknown_error
  rescue_from HandledError, with: :handle_defined_error
  before_action :disable_session_cookie_response

  private def disable_session_cookie_response
    request.session_options[:skip] = true
  end

  private def handle_defined_error(error)
    @error = "#{error.class}: #{error}"

    render status: error.status, json: {
      code: error.code,
      title: error.title,
      detail: error.detail,
    }
  end

  private def handle_unknown_error(error)
    @error = "#{error.class}: #{error}"

    render status: :internal_server_error, json: {
      code: "Unhandled Error",
      title: "GENERAL ERROR", # This needs to be string, else it will return empty object.
      detail: error.message,
    }
  end

  def append_info_to_payload(payload)
    super
    payload[:account_id] = @current_user&.id
    payload[:error] = @error
    payload[:response] = JSON.parse(response.body)&.filtered.to_s[0..10_000]
  end
end
