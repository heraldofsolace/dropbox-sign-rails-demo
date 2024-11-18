class DropboxSignService < ApplicationService
    attr_reader :signature_request

    def initialize(signature_request)
        @signature_request = signature_request
    end

    def call
        signature_request_api = Dropbox::Sign::SignatureRequestApi.new
        signature_request_signers = @signature_request.signers.map.with_index do |signer, order|
            sub_signer = Dropbox::Sign::SubSignatureRequestSigner.new
            sub_signer.email_address = signer.email
            sub_signer.name = signer.name
            sub_signer.order = order
            sub_signer
        end

        signing_options = Dropbox::Sign::SubSigningOptions.new
        signing_options.draw = true
        signing_options.type = true
        signing_options.upload = true
        signing_options.phone = true
        signing_options.default_type = "draw"

        data = Dropbox::Sign::SignatureRequestCreateEmbeddedRequest.new
        data.client_id = "ed845ceadfe7435cd6728fb6ceb8d714"
        data.title = @signature_request.subject
        data.subject = @signature_request.subject
        data.message = @signature_request.message
        data.signers = signature_request_signers
        data.signing_options = signing_options
        data.test_mode = true

        if @signature_request.file_url.present?
            data.file_urls = [@signature_request.file_url]
        else
            data.files = [File.open(ActiveStorage::Blob.service.path_for(@signature_request.document.key), "r")]
        end

        begin
            result = signature_request_api.signature_request_create_embedded(data)

            @signature_request.ds_signature_request_id = result.signature_request.signature_request_id
            result.signature_request.signatures.each do |signature|
                print signature.signature_id
                @signature_request.signers[signature.order.to_i].ds_signature_id = signature.signature_id
            end
            return @signature_request
        rescue Dropbox::Sign::ApiError => e
            puts "Exception when calling Dropbox Sign API: #{e}"
            return nil
        end
    end

    def generate_sign_url(signer_email)
        embedded_api = Dropbox::Sign::EmbeddedApi.new
        signer = @signature_request.signers.find_by(email: signer_email)

        begin
            return embedded_api.embedded_sign_url(signer.ds_signature_id)
        rescue Dropbox::Sign::ApiError => e
            puts "Exception when calling Dropbox Sign API: #{e}"
            return nil
        end
    end

    def check_status
        signature_request_api = Dropbox::Sign::SignatureRequestApi.new
        
        begin
            result = signature_request_api.signature_request_get(@signature_request.ds_signature_request_id)
            
            return result.signature_request.is_complete
        rescue Dropbox::Sign::ApiError => e
            puts "Exception when calling Dropbox Sign API: #{e}"
            return false
        end
    end

    def download_file
        signature_request_api = Dropbox::Sign::SignatureRequestApi.new

        begin
            file_bin = signature_request_api.signature_request_files(@signature_request.ds_signature_request_id)
            return file_bin
        rescue Dropbox::Sign::ApiError => e
            puts "Exception when calling Dropbox Sign API: #{e}"
            return nil
        end
    end
end
