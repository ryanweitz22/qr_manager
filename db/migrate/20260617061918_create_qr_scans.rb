class CreateQrScans < ActiveRecord::Migration[8.0]
  def change
    create_table :qr_scans do |t|
      t.references :qr_code, null: false, foreign_key: true
      t.string :ip_address
      t.text :user_agent
      t.text :referrer
      t.datetime :scanned_at

      t.timestamps
    end
  end
end
