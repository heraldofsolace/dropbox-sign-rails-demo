class CreateSignatureRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :signature_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.string :subject
      t.text :message

      t.timestamps
    end
  end
end
