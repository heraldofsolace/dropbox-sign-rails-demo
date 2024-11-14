require "application_system_test_case"

class SignatureRequestsTest < ApplicationSystemTestCase
  setup do
    @signature_request = signature_requests(:one)
  end

  test "visiting the index" do
    visit signature_requests_url
    assert_selector "h1", text: "Signature requests"
  end

  test "should create signature request" do
    visit signature_requests_url
    click_on "New signature request"

    fill_in "Message", with: @signature_request.message
    fill_in "Subject", with: @signature_request.subject
    fill_in "User", with: @signature_request.user_id
    click_on "Create Signature request"

    assert_text "Signature request was successfully created"
    click_on "Back"
  end

  test "should update Signature request" do
    visit signature_request_url(@signature_request)
    click_on "Edit this signature request", match: :first

    fill_in "Message", with: @signature_request.message
    fill_in "Subject", with: @signature_request.subject
    fill_in "User", with: @signature_request.user_id
    click_on "Update Signature request"

    assert_text "Signature request was successfully updated"
    click_on "Back"
  end

  test "should destroy Signature request" do
    visit signature_request_url(@signature_request)
    click_on "Destroy this signature request", match: :first

    assert_text "Signature request was successfully destroyed"
  end
end
