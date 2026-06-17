# Handles the public QR code redirect
# No login required — this is what happens when someone scans a QR code
class RedirectsController < ApplicationController

  def show
    # Find the QR code using the slug from the URL
    # e.g. /q/business-card-qr -> looks for slug = "business-card-qr"
    qr_code = QrCode.find_by(slug: params[:slug])

    # If no QR code found with this slug, show the error page
    if qr_code.nil?
      render :not_found, status: :not_found
      return
    end

    # If the QR code is inactive, show the error page
    unless qr_code.active?
      render :not_found, status: :not_found
      return
    end

    # Record this scan in the database — THIS IS THE TRACKING FEATURE
    qr_code.qr_scans.create!(
      ip_address: request.remote_ip,   # The visitor's IP address
      user_agent: request.user_agent,  # Their browser and device info
      referrer: request.referrer,      # The page they came from (or nil)
      scanned_at: Time.current         # The exact time of this scan
    )

    # Redirect the visitor to the destination URL
    # allow_other_host: true is required when redirecting to external websites
    redirect_to qr_code.destination_url, allow_other_host: true
  end
end