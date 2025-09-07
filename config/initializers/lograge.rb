Rails.application.configure do
  config.lograge.base_controller_class = "ActionController::API"
  config.lograge.enabled = true
  config.lograge.logger = AppLogger.traffic
  config.lograge.formatter = Lograge::Formatters::Json.new

  config.lograge.custom_options = lambda do |event|
    params = event.payload[:params]
      .except(:controller, :action, :format)
      .each_pair
      .map { |k, v| { key: k, value: v } }

    payload = {
      params: params,
      error: event.payload[:error],
      response: event.payload[:response],
    }

    payload
  end
end
