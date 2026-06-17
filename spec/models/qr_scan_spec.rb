require 'rails_helper'

RSpec.describe QrScan, type: :model do
  describe "associations" do
    it "belongs to a qr_code" do
      scan = build(:qr_scan)
      expect(scan.qr_code).to be_a(QrCode)
    end
  end

  describe "validations" do
    it "is valid with valid attributes" do
      scan = build(:qr_scan)
      expect(scan).to be_valid
    end

    it "is invalid without a qr_code" do
      scan = build(:qr_scan, qr_code: nil)
      expect(scan).not_to be_valid
    end
  end

  describe "recording" do
    it "stores ip address, user agent, and referrer" do
      qr = create(:qr_code)
      scan = create(:qr_scan,
        qr_code: qr,
        ip_address: "192.168.1.1",
        user_agent: "TestAgent/1.0",
        referrer: "https://twitter.com"
      )
      expect(scan.ip_address).to eq("192.168.1.1")
      expect(scan.user_agent).to eq("TestAgent/1.0")
      expect(scan.referrer).to eq("https://twitter.com")
    end
  end
end
