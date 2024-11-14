require "test_helper"

class SignatureRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @signature_request = signature_requests(:one)
  end

  test "should get index" do
    get signature_requests_url
    assert_response :success
  end

  test "should get new" do
    get new_signature_request_url
    assert_response :success
  end

  test "should create signature_request" do
    assert_difference("SignatureRequest.count") do
      post signature_requests_url, params: { signature_request: { message: @signature_request.message, subject: @signature_request.subject, user_id: @signature_request.user_id } }
    end

    assert_redirected_to signature_request_url(SignatureRequest.last)
  end

  test "should show signature_request" do
    get signature_request_url(@signature_request)
    assert_response :success
  end

  test "should get edit" do
    get edit_signature_request_url(@signature_request)
    assert_response :success
  end

  test "should update signature_request" do
    patch signature_request_url(@signature_request), params: { signature_request: { message: @signature_request.message, subject: @signature_request.subject, user_id: @signature_request.user_id } }
    assert_redirected_to signature_request_url(@signature_request)
  end

  test "should destroy signature_request" do
    assert_difference("SignatureRequest.count", -1) do
      delete signature_request_url(@signature_request)
    end

    assert_redirected_to signature_requests_url
  end
end
