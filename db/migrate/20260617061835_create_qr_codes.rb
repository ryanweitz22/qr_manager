class CreateQrCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :qr_codes do |t|
      t.string :name
      t.string :slug
      t.string :destination_url
      t.boolean :active

      t.timestamps
    end
  end
end
