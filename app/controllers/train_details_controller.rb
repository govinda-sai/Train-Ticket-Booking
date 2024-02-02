# frozen_string_literal: true

class TrainDetailsController < ApplicationController # rubocop:disable Style/Documentation,Metrics/ClassLength
  before_action :set_train_detail, only: %i[show update destroy]

  def index
    @train_details = TrainDetail.all

    render json: @train_details
  end

  def show
    render json: @train_detail
  end

  def create
    @train_detail = TrainDetail.new(train_detail_params)
    if valid?(@train_detail)
      render json: { message: 'train created', created_train: @train_detail }, status: :created if @train_detail.save
    else
      render json: { message: 'train could not be created', errors: @train_detail.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    if @train_detail.update(train_detail_params)
      render json: @train_detail
    else
      render json: { message: 'train could not be updated' }, status: :unprocessable_entity
    end
  end

  def destroy
    if @train_detail.destroy
      render json: { message: 'train deleted successfully' }, status: :ok
    else
      render json: { message: 'train could not be deleted' }, status: :unprocessable_entity
    end
  end

  def search # rubocop:disable Metrics/MethodLength
    search_term = params[:search_term]
    pattern = /\A#{search_term}/i

    @train_details = TrainDetail.or({ train_name: pattern },
                                    { train_number: pattern },
                                    { seats: pattern },
                                    { beginning_station: pattern },
                                    { destination_station: pattern },
                                    { stops: pattern },
                                    { start_time: pattern },
                                    { end_time: pattern })

    if @train_details.present?
      render json: @train_details
    else
      render json: { message: 'no matches found' }, status: :not_found
    end
  end

  def combination_search
    search_params = params.require(:train_detail).permit(:train_name, :train_number, :seats,
                                                         :beginning_station, :destination_station,
                                                         :stops, :start_time, :end_time)
    conditions = {}

    search_params.each do |key, value|
      conditions[key] = /#{value}/i if value.present?
    end

    @train_details = TrainDetail.or(conditions)

    render json: (@train_details.present? ? @train_details : { message: 'no records found' }),
           status: :not_found
  end

  private

  def set_train_detail
    @train_detail = TrainDetail.find(params[:id])
  rescue Mongoid::Errors::DocumentNotFound
    render json: { message: 'train not found' }, status: :not_found
  end

  def train_detail_params # rubocop:disable Metrics/MethodLength
    params.require(:train_detail).permit(
      :train_name,
      :train_number,
      :seats,
      :beginning_station,
      :destination_station,
      :start_time,
      :end_time,
      stops: [],
      price_for_stop: {}
    )
  end

  def valid?(train) # rubocop:disable Metrics/MethodLength,Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity
    @train = train

    fields = %i[train_name train_number seats beginning_station destination_station stops price_for_stop
                start_time end_time]

    fields.each do |field|
      if @train[field].blank?
        @train.errors.add(field, "can't be blank")
        return false
      end
    end

    if TrainDetail.exists?(@train.train_number)
      @train.errors.add(:train_number, 'should be unique')
      return false
    end

    if @train.seats.negative?
      @train.errors.add(:seats, "can't be negative")
      return false
    end

    if @train.beginning_station == @train.destination_station
      @train.errors.add(:beginning_station, '& Destination Station can\'t be same')
      return false
    end

    @train.errors.add(:start_time, "can't be greter than End Time") if @train.start_time > @train.end_time

    if @train.stops.present? && @train.price_for_stop.present?

      @train.stops.each do |stop|
        unless @train.price_for_stop.key?(stop.to_s)
          @train.errors.add(:price_for_stop, "for #{stop} is missing")
          return false
        end

        charge = @train.price_for_stop[stop.to_s]
        if charge.present? && charge.negative?
          @train.errors.add(:price_for_stop, "#{stop} can't be negative")
          return false
        end
      end
    end

    true
  end
end
