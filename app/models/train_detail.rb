# frozen_string_literal: true

class TrainDetail # rubocop:disable Style/Documentation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :train_name, type: String
  field :train_number, type: String
  field :seats, type: Integer
  field :beginning_station, type: String
  field :destination_station, type: String
  field :stops, type: Array
  field :price_for_stop, type: Hash
  field :start_time, type: DateTime
  field :end_time, type: DateTime

  field :booking_details_id, type: BSON::ObjectId

  def bookings
    BookingDetails.where(booking_details_id: booking_details_id)
  end
end
