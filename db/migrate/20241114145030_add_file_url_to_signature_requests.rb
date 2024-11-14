class AddFileUrlToSignatureRequests < ActiveRecord::Migration[7.1]
  def change
    add_column :signature_requests, :file_url, :string
  end
end
