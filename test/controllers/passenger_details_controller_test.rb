require "test_helper"

class PassengerDetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @passenger_detail = passenger_details(:one)
  end

  test "should get index" do
    get passenger_details_url, as: :json
    assert_response :success
  end

  test "should create passenger_detail" do
    assert_difference("PassengerDetail.count") do
      post passenger_details_url, params: { passenger_detail: { age: @passenger_detail.age, email: @passenger_detail.email, gender: @passenger_detail.gender, name: @passenger_detail.name, phone: @passenger_detail.phone } }, as: :json
    end

    assert_response :created
  end

  test "should show passenger_detail" do
    get passenger_detail_url(@passenger_detail), as: :json
    assert_response :success
  end

  test "should update passenger_detail" do
    patch passenger_detail_url(@passenger_detail), params: { passenger_detail: { age: @passenger_detail.age, email: @passenger_detail.email, gender: @passenger_detail.gender, name: @passenger_detail.name, phone: @passenger_detail.phone } }, as: :json
    assert_response :success
  end

  test "should destroy passenger_detail" do
    assert_difference("PassengerDetail.count", -1) do
      delete passenger_detail_url(@passenger_detail), as: :json
    end

    assert_response :no_content
  end
end
