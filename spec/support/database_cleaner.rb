RSpec.configure do |config|
  config.use_transactional_fixtures = false

  # Before the test suite starts, clean the tables
  config.prepend_before(:suite) do
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
