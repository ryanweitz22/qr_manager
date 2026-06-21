class Admin::QrCodesController < Admin::BaseController
  before_action :set_qr_code, only: [:show, :edit, :update, :destroy, :download_qr, :archive, :unarchive]

  def index
    if params[:q].present?
      @qr_codes = QrCode.active_codes.where("name ILIKE ?", "%#{params[:q]}%").order(created_at: :desc)
    else
      @qr_codes = QrCode.active_codes.order(created_at: :desc)
    end
  end

  def archived
    @qr_codes = QrCode.archived_codes.order(created_at: :desc)
  end

  def show
    @pagy, @scans = pagy(:offset, @qr_code.qr_scans.order(scanned_at: :desc), limit: 5)
    @scans_by_day = @qr_code.scans_by_day
  end

  def new
    @qr_code = QrCode.new
  end

  def create
    @qr_code = QrCode.new(qr_code_params)
    if @qr_code.save
      redirect_to admin_qr_code_path(@qr_code), notice: "QR code created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @qr_code.update(qr_code_params)
      redirect_to admin_qr_code_path(@qr_code), notice: "QR code updated successfully!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @qr_code.destroy
    redirect_to admin_qr_codes_path, notice: "QR code deleted successfully."
  end

  def archive
    @qr_code.update(archived: true, active: false)
    redirect_to admin_qr_codes_path, notice: "QR code archived successfully."
  end

  def unarchive
    @qr_code.update(archived: false, active: true)
    redirect_to admin_qr_code_path(@qr_code), notice: "QR code restored successfully."
  end

  def download_qr
    png_data = @qr_code.qr_image_png(request.base_url)
    send_data png_data,
              type: "image/png",
              filename: "#{@qr_code.slug}-qrcode.png",
              disposition: "attachment"
  end

  private

  def set_qr_code
    @qr_code = QrCode.find(params[:id])
  end

  def qr_code_params
    params.require(:qr_code).permit(:name, :slug, :destination_url, :active)
  end
end
