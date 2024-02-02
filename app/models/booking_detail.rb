# frozen_string_literal: true

class BookingDetail # rubocop:disable Style/Documentation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :pnr_number, type: String
  field :seats, type: Integer
  field :from_station, type: String
  field :destination_station, type: String
  field :date_of_booking, type: DateTime
  field :travel_date, type: DateTime
  field :status, type: String

  field :passenger_details_ids, type: Array, default: []

  field :train_details_id, type: BSON::ObjectId

  def train
    TrainDetail.find(train_details_id)
  end

  def passengers
    PassengerDetail.in(id: passenger_details_ids)
  end
end
