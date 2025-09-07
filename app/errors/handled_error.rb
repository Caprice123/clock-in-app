class HandledError < StandardError
  class << self
    def default(
      title: config[:title],
      detail: config[:detail],
      code: config[:code],
      status: config[:status]
    )
      config[:detail] = detail
      config[:title] = title
      config[:code] = code
      config[:status] = status
    end

    def config
      @config ||= {}
    end
  end

  attr_accessor :status, :detail, :title, :code

  def initialize(
    title: nil,
    detail: nil,
    code: nil,
    status: nil
  )
    @title = title || self.class.config[:title]
    @detail = detail || self.class.config[:detail]
    @code = code || self.class.config[:code]
    @status = status || self.class.config[:status]

    super(title)
  end
end
