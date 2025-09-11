require "database_cleaner/active_record"

RSpec.configure do |config|
  config.use_transactional_fixtures = false

  # Configure DatabaseCleaner to only operate in test environment
  config.prepend_before(:suite) do
    # Ensure we're in test environment
    abort "DatabaseCleaner should only run in test environment!" unless Rails.env.test?

    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  # Signal DatabaseCleaner before test starts
  config.before(:each) do
    DatabaseCleaner.start
  end

  # Clean the database after each test finishes
  config.after(:each) do
    DatabaseCleaner.clean
  end
end
