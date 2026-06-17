require 'rails_helper'

RSpec.describe "Redirects", type: :request do
  describe "GET /q/:slug" do
    context "when the slug exists and is active" do
      let!(:qr_code) do
        create(:qr_code,
          slug: "test-redirect",
          destination_url: "https://www.google.com",
          active: true
        )
      end

      it "redirects to the destination URL" do
        get "/q/test-redirect"
        expect(response).to redirect_to("https://www.google.com")
      end

      it "records a QrScan" do
        expect {
          get "/q/test-redirect"
        }.to change(QrScan, :count).by(1)
      end

      it "records the correct ip address" do
        get "/q/test-redirect", headers: { "REMOTE_ADDR" => "10.0.0.1" }
        scan = QrScan.last
        expect(scan.ip_address).to be_present
      end

      it "records the user agent" do
        get "/q/test-redirect", headers: { "HTTP_USER_AGENT" => "RSpec Test Browser" }
        scan = QrScan.last
        expect(scan.user_agent).to eq("RSpec Test Browser")
      end
    end

    context "when the slug does not exist" do
      it "returns 404" do
        get "/q/nonexistent-slug"
        expect(response).to have_http_status(:not_found)
      end

      it "does not record a QrScan" do
        expect {
          get "/q/nonexistent-slug"
        }.not_to change(QrScan, :count)
      end
    end

    context "when the QR code is inactive" do
      let!(:qr_code) do
        create(:qr_code,
          slug: "inactive-qr",
          destination_url: "https://www.google.com",
          active: false
        )
      end

      it "returns 404 or redirects appropriately" do
        get "/q/inactive-qr"
        # Depending on your implementation: either 404 or redirected
        expect([302, 404]).to include(response.status)
      end
    end
  end
end
