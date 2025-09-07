Dir[Rails.root.join("spec/helpers/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
  config.include ActionView::Helpers::NumberHelper
  config.include ActiveJob::TestHelper
  config.include Rails.application.routes.url_helpers

  # Custom helpers
  config.include ResponseHelpers
end
