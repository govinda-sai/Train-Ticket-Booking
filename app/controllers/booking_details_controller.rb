# frozen_string_literal: true

class BookingDetailsController < ApplicationController # rubocop:disable Style/Documentation,Metrics/ClassLength
  before_action :set_booking_detail, only: %i[show update destroy]

  def index
    render json: mapping(BookingDetail.all)
  end

  def show
    render json: mapping([@booking_detail])
  end

  def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @booking_detail = BookingDetail.new(booking_detail_params)
    @booking_detail.pnr_number = "PNR#{generate_pnr_number}"

    if valid?(@booking_detail)
      passenger_ids = params[:passenger_details_ids]

      if passenger_ids.present? && passenger_ids.length == @booking_detail.seats
        @booking_detail.passenger_details_ids = passenger_ids

        if @booking_detail.save
          render json: { message: 'booking placed', created_booking_details: mapping([@booking_detail]) },
                 status: :created
        else
          render json: { message: 'failed to book seats', errors: @booking_detail.errors.full_messages },
                 status: :unprocessable_entity
        end
      else
        render json: { message: 'all passenger details must be entered' }, status: :unprocessable_entity
      end
    else
      render json: { message: 'booking could not be created', errors: @booking_detail.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    if @booking_detail.update(booking_detail_params)
      render json: { message: 'booking updated successfully' }, status: :ok
    else
      render json: { message: 'booking could not be updated' }, status: :unprocessable_entity

    end
  end

  def destroy
    if @booking_detail.destroy
      render json: { message: 'booking deleted successfully' }, status: :ok
    else
      render json: { message: 'booking could not be deleted' }, status: :unprocessable_entity
    end
  end

  def search
    search_term = params[:search_term]
    pattern = /#{search_term}/i

    @bookings = BookingDetail.or({ pnr_number: pattern },
                                 { seats: pattern },
                                 { from_station: pattern },
                                 { destination_station: pattern },
                                 { date_of_booking: pattern },
                                 { travel_date: pattern },
                                 { status: pattern })

    render json: (@bookings.present? ? @bookings : { message: 'no matches found' }), status: :not_found
  end

  # combinational search
  def combination_search # rubocop:disable Metrics/MethodLength
    search_params = params.require(:booking_detail)
                          .permit(:pnr_number, :seats, :passenger_details_id, :train_details_id, :from_station,
                                  :destination_station, :date_of_booking, :travel_date, :status, :train_number)
    conditions = {}

    search_params.each do |key, value|
      conditions[key] = /#{value}/i if value.present?
    end

    @booking_details = BookingDetail.or(conditions)

    if @booking_details.present?
      render json: @booking_details
    else
      render json: { message: 'no records found' }, status: :not_found
    end
  end

  # booked trains list
  def booked_trains
    status = 'confirmed'
    booked_collections = BookingDetail.where(status: status)

    if booked_collections.present?
      render json: booked_collections, status: :ok
    else
      render json: { message: 'no booked collections found' }, status: :not_found
    end
  end

  # cancel booking
  def cancel_booking
    @booking = BookingDetail.find(params[:id])
    if (@booking.status = 'canceled')
      if @booking.save
        render json: { message: 'booking canceled succesfully' }, status: :ok
      else
        render json: { message: 'failed to cancel booking' }, status: :unprocessable_entity
      end
    end
  rescue Mongoid::Errors::DocumentNotFound
    render json: { message: 'booking id not found' }, status: :not_found
  end

  # change schedule
  def change_schedule # rubocop:disable Metrics/MethodLength
    booking = BookingDetail.find(params[:id])
    if booking.status != 'canceled'
      travel_date_param = params[:travel_date]
      if travel_date_param > booking.travel_date
        booking.travel_date = travel_date_param
        if booking.save
          render json: { message: 'schedule changed successfully' }, status: :ok
        else
          render json: { message: 'failed to change schedule' }, status: :unprocessable_entity
        end
      else
        render json: { message: 'schedule must be in future' }, status: :unprocessable_entity
      end
    end
  rescue Mongoid::Errors::DocumentNotFound
    render json: { message: 'booking id not found' }, status: :not_found
  end

  # search by train name or train number
  def search_by_train # rubocop:disable Metrics/MethodLength
    search_term = params[:train_name] || params[:train_number]

    if search_term.present?
      train_detail = TrainDetail.or({ train_name: search_term }, { train_number: search_term }).first

      if train_detail.present?
        booking_details = BookingDetail.where(train_details_id: train_detail.id)
        render json: { bookings: booking_details }
      else
        render json: { error: 'train not found' }, status: :not_found
      end
    else
      render json: { error: 'train name or train number parameter is missing' }, status: :bad_request
    end
  rescue Mongoid::Errors::DocumentNotFound
    render json: { error: 'train not found' }, status: :not_found
  end

  # search by email
  def search_by_email # rubocop:disable Metrics/MethodLength
    email = params[:email]

    if email.present?
      passenger = PassengerDetail.find_by(email: email)
      if passenger.present?
        booking_details = BookingDetail.find_by(passenger_details_id: passenger.id)
        render json: booking_details, status: :ok
      else
        render json: { message: 'passenger not found' }, status: :not_found
      end
    else
      render json: { message: 'email can\'t be blank' }, status: :bad_request
    end
  rescue Mongoid::Errors::DocumentNotFound
    render json: { error: 'passenger email not found' }, status: :not_found
  end

  private

  def set_booking_detail
    @booking_detail = BookingDetail.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render json: { message: 'booking id not found' }, status: :not_found
  end

  # request parameters
  def booking_detail_params
    params.require(:booking_detail).permit(:seats, :train_details_id, :from_station,
                                           :destination_station, :date_of_booking, :travel_date, :status,
                                           passenger_details_ids: [])
  end

  # pnr number generation
  def generate_pnr_number
    loop do
      pnr_number = rand(10**9..10**10 - 1).to_s
      return pnr_number unless BookingDetail.exists?(pnr_number: pnr_number)
    end
  end

  def valid?(booking) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    @booking = booking

    fields = %i[seats from_station destination_station date_of_booking travel_date status train_details_id
                passenger_details_ids]

    fields.each do |field|
      if @booking[field].blank?
        @booking.errors.add(field, 'can\'t be blank')
        return false
      end
    end

    if @booking.seats.positive?
      if @booking.seats > @booking.train.seats
        @booking.errors.add(:seats, "- available train seats: #{@booking.train.seats}")
        return false
      end
    else
      @booking.errors.add(:seats, "can't be negative")
      return false
    end

    if @booking.from_station != @booking.destination_station
      if @booking.from_station != @booking.train.beginning_station
        @booking.errors.add(:from_station, "is not available, train starts from #{@booking.train.beginning_station}")
        return false
      elsif @booking.destination_station != @booking.train.destination_station
        @booking.errors.add(:destination_station,
                            "is not available, train goes to #{@booking.train.destination_station}")
        return false
      end
    else
      @booking.errors.add(:from_station, "& Destination Station can't be same")
      return false
    end

    if @booking.travel_date != @booking.train.start_time
      @booking.errors.add(:travel_date, "is not available, available train time: #{@booking.train.start_time}")
      return false
    end

    if @booking.travel_date < @booking.date_of_booking
      @booking.errors.add(:date_of_booking, 'can\'t be greater than Travel Date')
      return false
    end

    status_pattern = /\A\b(pending|confirmed|canceled)\b\z/i
    unless @booking.status.match?(status_pattern)
      @booking.errors.add(:status, 'is invalid')
      return false
    end

    true
  end

  def mapping(booking) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    booking.map do |booking| # rubocop:disable Lint/ShadowingOuterLocalVariable
      {
        booking_id: booking.id,
        pnr_number: booking.pnr_number,
        seats_booked: booking.seats,
        passenger_details: booking.passengers.map do |passenger|
          {
            passenger_name: passenger.name,
            passenger_age: passenger.age,
            passenger_gender: passenger.gender,
            passenger_email: passenger.email,
            passenger_phone: passenger.phone
          }
        end,
        from_station: booking.from_station,
        destination: booking.destination_station,
        train_details: { train_name: booking.train&.train_name,
                         train_number: booking.train&.train_number },
        date_of_booking: booking.date_of_booking,
        travel_date: booking.travel_date,
        status: booking.status
      }
    end
  end
end
