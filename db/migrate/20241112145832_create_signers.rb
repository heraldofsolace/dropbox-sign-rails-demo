class CreateSigners < ActiveRecord::Migration[7.1]
  def change
    create_table :signers do |t|
      t.string :email
      t.string :name
      t.string :role
      t.references :signature_request, null: false, foreign_key: true

      t.timestamps
    end
  end
end
