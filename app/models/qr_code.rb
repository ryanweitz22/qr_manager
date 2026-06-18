class QrCode < ApplicationRecord
  # RELATIONSHIP — one QR code can have many scans
  # If we delete a QR code, all its scans get deleted too (dependent: :destroy)
  has_many :qr_scans, dependent: :destroy

  # SCOPES — filters for querying the database
  scope :active_codes, -> { where(archived: false) }
  scope :archived_codes, -> { where(archived: true) }

  # VALIDATIONS — rules that must pass before saving to the database
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :destination_url, presence: true
  validates :destination_url, format: {
    with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
    message: "must be a valid URL starting with http:// or https://"
  }

  # CALLBACK — runs automatically before validating a new record
  before_validation :generate_slug, on: :create

  def qr_image_png_base64(base_url)
    redirect_url = "#{base_url}/q/#{slug}"
    qr = RQRCode::QRCode.new(redirect_url)
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
    Base64.strict_encode64(png.to_s)
  end

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

  def scans_by_day
    qr_scans
      .where("scanned_at >= ?", 30.days.ago)
      .group("DATE(scanned_at)")
      .count
  end

  private

  def generate_slug
    self.slug ||= name.to_s.parameterize
  end
end
