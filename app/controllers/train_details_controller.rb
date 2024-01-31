# frozen_string_literal: true

class TrainDetailsController < ApplicationController # rubocop:disable Style/Documentation
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
    if valid?(@train_detail)
      if @train_detail.update(train_detail_params)
        render json: @train_detail
      else
        render json: { message: 'train could not be updated' }, status: :unprocessable_entity
      end
    else
      render json: { message: 'train could not be updated', errors: @train_detail.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def destroy
    if @train_detail.destroy
      render json: { message: 'train deleted successfully' }, status: :ok
    else
      render json: { message: 'train could not be deleted' }, status: :unprocessable_entity
    end
  end

  def search
    search_term = params[:search_term]
    pattern = /\A#{search_term}/i

    @train_details = TrainDetail.or({ train_name: pattern }, { train_number: pattern },
                                    { beginning_station: pattern }, { destination_station: pattern },
                                    { start_time: pattern }, { end_time: pattern })

    if @train_details.present?
      render json: @train_details
    else
      render json: { message: 'train name not found' }, status: :not_found
    end
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

  def valid?(train) # rubocop:disable Metrics/MethodLength
    @train = train

    fields = %i[train_name train_number seats beginning_station destination_station stops price_for_stop
                start_time end_time]

    fields.each do |field|
      @train.errors.add(field, "can't be blank") if @train[field].blank?
    end

    if @train.price_for_stop.present?
      @train.price_for_stop.each do |station, charge|
        @train.errors.add(:price_for_stop, "- charge for #{station} can't be negative") unless charge.positive?
      end
    else
      @train.errors.add(:price_for_stop, "- charges can't be blank")
    end

    true
  end
end
