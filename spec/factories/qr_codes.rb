FactoryBot.define do
  factory :qr_code do
    sequence(:name) { |n| "Test QR Code #{n}" }
    sequence(:slug) { |n| "test-qr-#{n}" }
    destination_url { "https://www.example.com" }
    active { true }
  end
end
