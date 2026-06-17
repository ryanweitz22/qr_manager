class QrScan < ApplicationRecord
  # RELATIONSHIP — each scan belongs to exactly one QR code
  # This matches the qr_code:references we used when generating the model
  belongs_to :qr_code
end