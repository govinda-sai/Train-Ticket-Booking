# frozen_string_literal: true

class PassengerDetailsController < ApplicationController # rubocop:disable Style/Documentation
  before_action :set_passenger_detail, only: %i[show update destroy]

  def index
    @passenger_details = PassengerDetail.all

    render json: @passenger_details
  end

  def show
    render json: @passenger_detail
  end

  def create
    @passenger_detail = PassengerDetail.new(passenger_detail_params)
    if valid?(@passenger_detail)
      if @passenger_detail.save
        render json: { message: 'passenger account created', created_passenger: @passenger_detail }, status: :created
      end
    else
      render json: { message: 'passenger could not be created', errors: @passenger_detail.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    if valid?(@passenger_detail)
      if @passenger_detail.update(passenger_detail_params)
        render json: @passenger_detail, status: :ok
      else
        render json: { message: 'passenger cound not be updated' }, status: :unprocessable_entity
      end
    else
      render json: { message: 'passenger could not be updated', errors: @passenger_detail.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    if @passenger_detail.destroy
      render json: { message: 'passenger deleted successfully' }, status: :ok
    else
      render json: { message: 'passenger could not be deleted' }, status: :unprocessable_entity
    end
  end

  private

  def set_passenger_detail
    @passenger_detail = PassengerDetail.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render json: { message: 'passenger not found' }, status: :not_found
  end

  def passenger_detail_params
    params.require(:passenger_detail).permit(:name, :age, :gender, :email, :phone, :booking_details_id)
  end

  def valid?(passenger) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity
    @passenger = passenger

    fields = %i[name age gender email phone]

    fields.each do |field|
      @passenger.errors.add(field, "- can't be blank") if @passenger[field].blank?
    end

    if !@passenger.age.positive? || @passenger.age > 100
      @passenger.errors.add(:age, '- invalid age')
      return false
    end

    gender_pattern = /\A\b(male|female|other)\b\z/i
    unless @passenger.gender.match?(gender_pattern)
      @passenger.errors.add(:gender, '- invalid gender')
      return false
    end

    email_pattern = /\A[\w_.]+@\w+[.]\w+\z/
    unless @passenger.email.match?(email_pattern)
      @passenger.errors.add(:email, '- invalid email address') unless @passenger.email.match?(email_pattern)
      return false
    end

    true
  end
end
