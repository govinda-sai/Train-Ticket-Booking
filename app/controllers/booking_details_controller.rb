# frozen_string_literal: true

class BookingDetailsController < ApplicationController # rubocop:disable Style/Documentation,Metrics/ClassLength
  before_action :set_booking_detail, only: %i[show update destroy]

  def index # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @booking_details = BookingDetail.all.map do |booking|
      {
        booking_id: booking.id,
        pnr_number: booking.pnr_number,
        seats_booked: booking.seats,
        passenger_details: booking.passengers.map do |passenger|
          {
            passenger_id: passenger.id,
            passenger_name: passenger.name,
            passenger_age: passenger.age,
            passenger_gender: passenger.gender,
            passenger_email: passenger.email,
            passenger_phone: passenger.phone
          }
        end,
        from_station: booking.from_station,
        destination: booking.destination_station,
        train_id: booking.train&.id,
        train_name: booking.train&.train_name,
        train_number: booking.train&.train_number,
        date_of_booking: booking.date_of_booking,
        travel_date: booking.travel_date,
        status: booking.status
      }
    end

    render json: @booking_details
  end

  def show
    render json: @booking_detail
  end

  def create
    @booking_detail = BookingDetail.new(booking_detail_params)
    @booking_detail.pnr_number = "PNR#{generate_pnr_number}"

    if valid?(@booking_detail)
      if @booking_detail.save
        render json: { message: 'booking created', created_booking_details: @booking_detail }, status: :created
      end
    else
      render json: { message: 'booking could not be created', errors: @booking_detail.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    if valid?(@booking_detail)
      if @booking_detail.update(booking_detail_params)
        render json: { message: 'booking updated successfully' }, status: :ok
      else
        render json: { message: 'booking could not be updated' }, status: :unprocessable_entity
      end
    else
      render json: { message: 'booking could not be updated', errors: @booking_detail.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    if @booking_detail.destroy
      render json: { message: 'booking deleted successfully' }, status: :ok
    else
      render json: { message: 'booking could not be deleted' }, status: :unprocessable_entity
    end
  end

  # booked trains list
  def booked_trains
    status = 'confirmed'
    booked_collections = BookingDetail.where(status: status)

    if booked_collections.present?
      render json: booked_collections, status: :ok
    else
      render json: { message: 'No booked collections found' }, status: :not_found
    end
  end

  # cancel booking
  def cancel_booking # rubocop:disable Metrics/MethodLength
    @booking = BookingDetail.find(params[:id])
    if @booking.present?
      @booking.status = 'canceled'
      if @booking.save
        render json: { message: 'booking canceled succesfully' }, status: :ok
      else
        render json: { message: 'failed to cancel booking' }, status: :unprocessable_entity
      end
    else
      render json: { message: 'booking id not found' }, status: :unprocessable_entity
    end
  end

  # change schedule
  def change_schedule # rubocop:disable Metrics/MethodLength
    booking = BookingDetail.find(params[:id])

    if booking.present?
      if booking.status != 'canceled'
        travel_date_param = params[:travel_date]
        if travel_date_param > booking.travel_date
          booking.travel_date = travel_date_param
          if booking.save # rubocop:disable Metrics/BlockNesting
            render json: { message: 'schedule changed successfully' }, status: :ok
          else
            render json: { message: 'failed to change schedule' }, status: :unprocessable_entity
          end
        else
          render json: { message: 'schedule must be in future' }, status: :unprocessable_entity
        end
      end
    else
      render json: { messsage: 'no booking found' }, status: :not_found
    end
  end

  private

  def set_booking_detail
    @booking_detail = BookingDetail.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render json: { message: 'booking id not found' }, status: :not_found
  end

  def booking_detail_params
    params.require(:booking_detail).permit(:seats, :passenger_details_id, :train_details_id, :from_station,
                                           :destination_station, :date_of_booking, :travel_date, :status)
  end

  def generate_pnr_number
    loop do
      pnr_number = SecureRandom.hex(5).upcase
      return pnr_number unless BookingDetail.exists?(pnr_number: pnr_number)
    end
  end

  def valid?(booking) # rubocop:disable Metrics/MethodLength
    @booking = booking

    fields = %i[seats from_station destination_station date_of_booking travel_date status passenger_details_id
                train_details_id]

    fields.each do |field|
      if @booking[field].blank?
        @booking.errors.add(field, '- can\'t be blank')
        return false
      end
    end

    @booking.errors.add(:seats, '- seats can\'t be negative') if @booking.seats.negative?

    status_pattern = /\A\b(pending|confirmed|canceled)\b\z/i
    unless @booking.status.match?(status_pattern)
      @booking.errors.add(:status, '- invalid status')
      return false
    end

    true
  end
end
