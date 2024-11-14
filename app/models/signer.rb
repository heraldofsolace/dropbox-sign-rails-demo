class Signer < ApplicationRecord
  belongs_to :signature_request
  validates :email, presence: true
  validates :name, presence: true
  validates :role, presence: true
end
