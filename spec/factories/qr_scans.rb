FactoryBot.define do
  factory :qr_scan do
    qr_code { nil }
    ip_address { "MyString" }
    user_agent { "MyText" }
    referrer { "MyText" }
    scanned_at { "2026-06-17 08:19:18" }
  end
end
