# Handles all QR code management in the admin area
# Inherits from Admin::BaseController so login is always required
class Admin::QrCodesController < Admin::BaseController

  # Run set_qr_code before these actions
  # These actions need to find a specific QR code first
  before_action :set_qr_code, only: [:show, :edit, :update, :destroy, :download_qr]

  # INDEX — list all QR codes
  # URL: GET /admin/qr_codes
  def index
    # If a search term was submitted, filter QR codes by name
    # ILIKE is PostgreSQL case-insensitive search
    # % on both sides means "contains this text anywhere in the name"
    if params[:q].present?
      @qr_codes = QrCode.where("name ILIKE ?", "%#{params[:q]}%").order(created_at: :desc)
    else
      # No search — show all QR codes newest first
      @qr_codes = QrCode.all.order(created_at: :desc)
    end
  end

  # SHOW — display one QR code with full details and scan history
  # URL: GET /admin/qr_codes/:id
  def show
  @scans = @qr_code.qr_scans.order(scanned_at: :desc).limit(50)
  @scans_by_day = @qr_code.scans_by_day
  end

  # NEW — show the blank form to create a new QR code
  # URL: GET /admin/qr_codes/new
  def new
    # Create an empty QR code object so the form has something to work with
    @qr_code = QrCode.new
  end

  # CREATE — save a new QR code to the database
  # URL: POST /admin/qr_codes
  def create
    # Build a new QR code with the data from the submitted form
    @qr_code = QrCode.new(qr_code_params)
    if @qr_code.save
      # Saved successfully — go to the detail page with a success message
      redirect_to admin_qr_code_path(@qr_code), notice: "QR code created successfully!"
    else
      # Validation failed — show the form again with error messages
      render :new, status: :unprocessable_entity
    end
  end

  # EDIT — show the form to edit an existing QR code
  # URL: GET /admin/qr_codes/:id/edit
  def edit
    # @qr_code is already set by before_action :set_qr_code
  end

  # UPDATE — save the edited QR code to the database
  # URL: PATCH /admin/qr_codes/:id
  def update
    if @qr_code.update(qr_code_params)
      redirect_to admin_qr_code_path(@qr_code), notice: "QR code updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DESTROY — delete a QR code and all its scans
  # URL: DELETE /admin/qr_codes/:id
  def destroy
    @qr_code.destroy
    redirect_to admin_qr_codes_path, notice: "QR code deleted successfully."
  end

  # DOWNLOAD_QR — sends the QR code as a downloadable PNG file
  # URL: GET /admin/qr_codes/:id/download_qr
  def download_qr
    # Generate the PNG binary data
    png_data = @qr_code.qr_image_png(request.base_url)
    # send_data sends the file to the browser as a download
    send_data png_data,
              type: "image/png",
              filename: "#{@qr_code.slug}-qrcode.png",
              disposition: "attachment"
  end

  private

  # Find the QR code from the database using :id from the URL
  # e.g. /admin/qr_codes/3 finds QrCode with id = 3
  def set_qr_code
    @qr_code = QrCode.find(params[:id])
  end

  # Strong parameters — only allow these specific fields from the form
  # Security feature — prevents hackers submitting extra hidden fields
  def qr_code_params
    params.require(:qr_code).permit(:name, :slug, :destination_url, :active)
  end
end