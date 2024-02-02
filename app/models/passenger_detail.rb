# frozen_string_literal: true

class PassengerDetail # rubocop:disable Style/Documentation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :age, type: Integer
  field :gender, type: String
  field :email, type: String
  field :phone, type: String

  field :booking_details_id, type: BSON::ObjectId

  # def booking
  #   BookingDetail.find(booking_details_id)
  # end
end
