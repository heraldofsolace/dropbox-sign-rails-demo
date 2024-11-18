class AddDsSignatureRequestIdToSignatureRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :signature_requests, :ds_signature_request_id, :string
  end
end
