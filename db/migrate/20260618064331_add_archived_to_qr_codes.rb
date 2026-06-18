class AddArchivedToQrCodes < ActiveRecord::Migration[8.0]
  def change
    add_column :qr_codes, :archived, :boolean, default: false, null: false
  end
end
