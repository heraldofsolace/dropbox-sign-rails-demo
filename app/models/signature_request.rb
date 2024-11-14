class SignatureRequest < ApplicationRecord
  belongs_to :user
  has_one_attached :document
  has_many :signers, dependent: :destroy
  accepts_nested_attributes_for :signers, reject_if: :all_blank, allow_destroy: true

  validates :subject, presence: true
  validates :message, presence: true
  validates :document, attached: { message: "needs to be provided if file URL is empty" }, if: ->{ file_url.blank? }
  validates :document, content_type: ["application/pdf"], if: ->{ file_url.blank? }
  validates_associated :signers

  def get_doc
    return file_url unless file_url.blank?
    return document.filename
  end
end
