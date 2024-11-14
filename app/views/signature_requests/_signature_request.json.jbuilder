json.extract! signature_request, :id, :user_id, :document, :subject, :message, :created_at, :updated_at
json.url signature_request_url(signature_request, format: :json)
json.document url_for(signature_request.document)
