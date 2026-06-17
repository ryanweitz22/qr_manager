# This file creates starter data in the database
# Run with: rails db:seed
# find_or_create_by! means: only create if it does not already exist
# This makes it safe to run multiple times without creating duplicates

# Create the admin user for logging in
admin = AdminUser.find_or_create_by!(email: 'admin@example.com') do |user|
  user.password = 'password123'
  user.password_confirmation = 'password123'
end
puts "✅ Admin user ready: #{admin.email} / password123"

# Create a sample QR code for testing
qr = QrCode.find_or_create_by!(slug: 'sample-qr') do |q|
  q.name = 'Sample QR Code'
  q.destination_url = 'https://www.google.com'
  q.active = true
end
puts "✅ Sample QR code ready: /q/#{qr.slug} -> #{qr.destination_url}"