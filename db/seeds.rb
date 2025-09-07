# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create 10 test users
user_names = [
  "Alice Johnson",
  "Bob Smith", 
  "Charlie Brown",
  "Diana Prince",
  "Edward Norton",
  "Fiona Green",
  "George Wilson",
  "Helen Davis",
  "Ivan Petrov",
  "Julia Roberts"
]

puts "Creating users..."
user_names.each do |name|
  user = User.find_or_create_by(name: name)
  if user.persisted?
    puts "✓ Created user: #{user.name}"
  else
    puts "✗ Failed to create user: #{name} - #{user.errors.full_messages.join(', ')}"
  end
end

puts "Seeding completed! Total users: #{User.count}"
