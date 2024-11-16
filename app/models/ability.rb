# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :create, SignatureRequest
    can :read, SignatureRequest do |signature_request|
      signature_request.user == user || signature_request.signers.count { |signer| signer.email == user.email } >= 1
    end

    can :sign, SignatureRequest do |signature_request|
      signature_request.signers.count { |signer| signer.email == user.email } >= 1
    end
  end
end
