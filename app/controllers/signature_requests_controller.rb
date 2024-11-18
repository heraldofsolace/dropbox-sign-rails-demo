class SignatureRequestsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  before_action :set_signature_request, only: %i[ show download ]

  # GET /signature_requests or /signature_requests.json
  def index
    @sent_signature_requests = current_user.signature_requests
    @received_signature_requests = SignatureRequest.joins(:signers).where(signers: { email: current_user.email }) 
  end

  # GET /signature_requests/1 or /signature_requests/1.json
  def show
    @signature_url = DropboxSignService.new(@signature_request).generate_sign_url(current_user.email) if can? :sign, @signature_request
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
        @updated_signature_request = DropboxSignService.call @signature_request
        if @updated_signature_request.nil?
          @signature_request.destroy
          flash.now[:alert] = "Error when calling the Dropbox Sign API"
          format.html { render :new, status: :internal_server_error }
          format.json { render json: { error: "Error when calling the Dropbox Sign API"}, status: :internal_server_error }
        else
          @updated_signature_request.save
          format.html { redirect_to @updated_signature_request, notice: "Signature request was successfully created." }
          format.json { render :show, status: :created, location: @updated_signature_request }
        end
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @updated_signature_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def download
    dropbox_sign_service = DropboxSignService.new(@signature_request)
    if dropbox_sign_service.check_status
      file = dropbox_sign_service.download_file
      send_file(file.path, type: "application.pdf", disposition: "attachment", filename: "signed.pdf")
    else
      if @signature_request.file_url.present?
        redirect_to @signature_request.file_url, status: :found, allow_other_host: true
      else
        redirect_to url_for(@signature_request.document), status: :found
      end
    end
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
