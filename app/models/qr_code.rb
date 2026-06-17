class QrCode < ApplicationRecord
  # RELATIONSHIP — one QR code can have many scans
  # If we delete a QR code, all its scans get deleted too (dependent: :destroy)
  has_many :qr_scans, dependent: :destroy

  # VALIDATIONS — rules that must pass before saving to the database
  # If any fail, the record will NOT save and the error message is shown to the user
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :destination_url, presence: true
  validates :destination_url, format: {
    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
    message: "must be a valid URL starting with http:// or https://"
  }

  # CALLBACK — runs automatically before validating a new record
  # Generates a slug from the name if one was not provided
  # "Business Card QR" becomes "business-card-qr"
  before_validation :generate_slug, on: :create

  # METHOD — generates the QR code as a PNG image in Base64 format
  # Base64 converts the image into a text string so it can be displayed in HTML
  # base_url is your app address e.g. "http://localhost:3000"
  def qr_image_png_base64(base_url)
    # Build the public redirect URL that gets encoded into the QR code
    redirect_url = "#{base_url}/q/#{slug}"

    # Use rqrcode to generate the QR code object
    qr = RQRCode::QRCode.new(redirect_url)

    # Convert to PNG using the chunky_png gem
    # module_px_size controls how big each square in the QR code is (higher = bigger image)
    png = qr.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false
    )

    # Convert the PNG to Base64 so it can be embedded directly in HTML as an image tag
    # This means no file needs to be saved to disk
    Base64.strict_encode64(png.to_s)
  end

  # METHOD — returns raw PNG binary for downloading
  # Used when the admin clicks the download button
  def qr_image_png(base_url)
    redirect_url = "#{base_url}/q/#{slug}"
    qr = RQRCode::QRCode.new(redirect_url)
    qr.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: "black",
      file: nil,
      fill: "white",
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false
    ).to_s
  end

  # METHOD — returns scan counts grouped by day for the last 30 days
  # Used to show the analytics bar chart on the detail page
  def scans_by_day
    qr_scans
      .where("scanned_at >= ?", 30.days.ago)
      .group("DATE(scanned_at)")
      .count
  end

  private

  # Automatically creates a slug from the name
  # ||= means only set this if slug is currently blank
  def generate_slug
    self.slug ||= name.to_s.parameterize
  end
end