require "test_helper"

class BookingDetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @booking_detail = booking_details(:one)
  end

  test "should get index" do
    get booking_details_url, as: :json
    assert_response :success
  end

  test "should create booking_detail" do
    assert_difference("BookingDetail.count") do
      post booking_details_url, params: { booking_detail: { date_of_booking: @booking_detail.date_of_booking, destination_station: @booking_detail.destination_station, from_station: @booking_detail.from_station, passenger_id: @booking_detail.passenger_id, pnr_number: @booking_detail.pnr_number, seats: @booking_detail.seats, status: @booking_detail.status, train_name: @booking_detail.train_name, train_number: @booking_detail.train_number } }, as: :json
    end

    assert_response :created
  end

  test "should show booking_detail" do
    get booking_detail_url(@booking_detail), as: :json
    assert_response :success
  end

  test "should update booking_detail" do
    patch booking_detail_url(@booking_detail), params: { booking_detail: { date_of_booking: @booking_detail.date_of_booking, destination_station: @booking_detail.destination_station, from_station: @booking_detail.from_station, passenger_id: @booking_detail.passenger_id, pnr_number: @booking_detail.pnr_number, seats: @booking_detail.seats, status: @booking_detail.status, train_name: @booking_detail.train_name, train_number: @booking_detail.train_number } }, as: :json
    assert_response :success
  end

  test "should destroy booking_detail" do
    assert_difference("BookingDetail.count", -1) do
      delete booking_detail_url(@booking_detail), as: :json
    end

    assert_response :no_content
  end
end
