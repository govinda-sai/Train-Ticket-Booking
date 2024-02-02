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
    if @passenger_detail.update(passenger_detail_params)
      render json: @passenger_detail, status: :ok
    else
      render json: { message: 'passenger cound not be updated' }, status: :unprocessable_entity
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
    # params.require(:passenger_detail).permit(:name, :age, :gender, :email, :phone, :booking_details_id)
    params.require(:passenger_detail).permit(:name, :age, :gender, :email, :phone)
  end

  def valid?(passenger) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    @passenger = passenger

    fields = %i[name age gender email phone]

    fields.each do |field|
      @passenger.errors.add(field, "can't be blank") if @passenger[field].blank?
    end

    if @passenger.name.length < 2
      @passenger.errors.add(:name, "can't be less than 2 characters")
      return false
    end

    if !@passenger.age.positive? || @passenger.age > 100
      @passenger.errors.add(:age, 'is invalid')
      return false
    end

    gender_pattern = /\A\b(male|female|other)\b\z/i
    unless @passenger.gender.match?(gender_pattern)
      @passenger.errors.add(:gender, 'is invalid')
      return false
    end

    email_pattern = /\A[\w_.]+@\w+[.]\w+\z/
    unless @passenger.email.match?(email_pattern)
      @passenger.errors.add(:email, 'is invalid') unless @passenger.email.match?(email_pattern)
      return false
    end

    phone_pattern = /\d{10}/
    unless @passenger.phone.match?(phone_pattern)
      @passenger.errors.add(:phone, 'must be of 10 digits')
      return false
    end

    true
  end
end
