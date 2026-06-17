require 'rails_helper'

RSpec.describe QrCode, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      qr = build(:qr_code)
      expect(qr).to be_valid
    end

    it "requires a name" do
      qr = build(:qr_code, name: nil)
      expect(qr).not_to be_valid
      expect(qr.errors[:name]).to include("can't be blank")
    end

    it "requires a destination_url" do
      qr = build(:qr_code, destination_url: nil)
      expect(qr).not_to be_valid
      expect(qr.errors[:destination_url]).to include("can't be blank")
    end

    it "requires slug to be unique" do
      create(:qr_code, slug: "my-unique-slug")
      duplicate = build(:qr_code, slug: "my-unique-slug")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to include("has already been taken")
    end
  end

  describe "associations" do
    it "has many qr_scans" do
      qr = create(:qr_code)
      create(:qr_scan, qr_code: qr)
      create(:qr_scan, qr_code: qr)
      expect(qr.qr_scans.count).to eq(2)
    end

    it "destroys associated qr_scans when deleted" do
      qr = create(:qr_code)
      create(:qr_scan, qr_code: qr)
      expect { qr.destroy }.to change(QrScan, :count).by(-1)
    end
  end

  describe "slug auto-generation" do
    it "auto-generates a slug from the name" do
      qr = create(:qr_code, name: "My Business Card", slug: nil)
      expect(qr.slug).to eq("my-business-card")
    end

    it "does not overwrite an existing slug" do
      qr = create(:qr_code, name: "My QR", slug: "custom-slug")
      expect(qr.slug).to eq("custom-slug")
    end
  end

  describe "QR code image generation" do
    it "generates a QR PNG for a given URL" do
      qr = create(:qr_code)
      png = qr.qr_image_png("https://qrmanager-production.up.railway.app")
      expect(png).to be_present
    end
  end
end
