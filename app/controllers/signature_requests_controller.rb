class SignatureRequestsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_signature_request, only: %i[ show sign ]

  # GET /signature_requests or /signature_requests.json
  def index
    @sent_signature_requests = current_user.signature_requests
    @received_signature_requests = SignatureRequest.joins(:signers).where(signers: { email: current_user.email }) 
  end

  # GET /signature_requests/1 or /signature_requests/1.json
  def show
  end

  # GET /signature_requests/new
  def new
    @signature_request = SignatureRequest.new
  end

  # POST /signature_requests or /signature_requests.json
  def create
    @signature_request = current_user.signature_requests.build(signature_request_params)

    respond_to do |format|
      if @signature_request.save
        format.html { redirect_to @signature_request, notice: "Signature request was successfully created." }
        format.json { render :show, status: :created, location: @signature_request }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @signature_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def sign
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_signature_request
      @signature_request = SignatureRequest.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def signature_request_params
      params.require(:signature_request).permit(:document, :file_url, :subject, :message, signers_attributes: [:email, :name, :role])
    end
end
