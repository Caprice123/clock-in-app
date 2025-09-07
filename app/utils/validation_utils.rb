module ValidationUtils
  class << self
    def validate_params(params:, required_fields:, optional_fields: [])
      errors = []
      params.permit(required_fields + optional_fields)

      required_fields.each do |field|
        errors << "Parameter #{field} wajib diisi}" if params[field].blank?
      end

      raise ParameterError::Error.new(title: "GENERAL ERROR", detail: errors.first, code: "1000", status: :bad_request) unless errors.empty?
    end
  end
end
