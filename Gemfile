source "https://rubygems.org"

ruby "3.3.0"

gem "rails", "~> 7.1.3"
gem "puma", ">= 5.0"
gem "bootsnap", require: false
gem "sqlite3", "~> 1.4"

gem "lograge"
gem "httpparty"
gem "dotenv"
gem "aasm"
gem "fast_jsonapi"

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
  gem "listen"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-commands-rspec"
  gem "spring-watcher-listen"

  gem "rubocop"
end

group :test do
  gem "database_cleaner"
  gem "factory_bot_rails"

  gem "parallel_tests"
  gem "rspec"
  gem "rspec-rails"
  gem "rspec-retry"
end
