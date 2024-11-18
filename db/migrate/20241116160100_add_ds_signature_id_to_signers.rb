class AddDsSignatureIdToSigners < ActiveRecord::Migration[7.1]
  def change
    add_column :signers, :ds_signature_id, :string
  end
end
