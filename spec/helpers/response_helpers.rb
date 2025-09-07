module ResponseHelpers
  def response_body
    @response_body ||= begin
      JSON.parse(response.body, symbolize_names: true)
    rescue StandardError
      {}
    end
  end
end
