require "test_helper"

class TrainDetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @train_detail = train_details(:one)
  end

  test "should get index" do
    get train_details_url, as: :json
    assert_response :success
  end

  test "should create train_detail" do
    assert_difference("TrainDetail.count") do
      post train_details_url, params: { train_detail: { beginning_station: @train_detail.beginning_station, destination_station: @train_detail.destination_station, end_time: @train_detail.end_time, no_of_seats: @train_detail.no_of_seats, price_for_stop: @train_detail.price_for_stop, start_time: @train_detail.start_time, stops: @train_detail.stops, train_name: @train_detail.train_name, train_number: @train_detail.train_number } }, as: :json
    end

    assert_response :created
  end

  test "should show train_detail" do
    get train_detail_url(@train_detail), as: :json
    assert_response :success
  end

  test "should update train_detail" do
    patch train_detail_url(@train_detail), params: { train_detail: { beginning_station: @train_detail.beginning_station, destination_station: @train_detail.destination_station, end_time: @train_detail.end_time, no_of_seats: @train_detail.no_of_seats, price_for_stop: @train_detail.price_for_stop, start_time: @train_detail.start_time, stops: @train_detail.stops, train_name: @train_detail.train_name, train_number: @train_detail.train_number } }, as: :json
    assert_response :success
  end

  test "should destroy train_detail" do
    assert_difference("TrainDetail.count", -1) do
      delete train_detail_url(@train_detail), as: :json
    end

    assert_response :no_content
  end
end
