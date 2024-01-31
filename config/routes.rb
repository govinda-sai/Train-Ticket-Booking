# frozen_string_literal: true

Rails.application.routes.draw do
  resources :train_details do
    collection do
      get 'search'
    end
  end
  resources :booking_details do
    collection do
      get 'booked_trains'
    end
    member do
      put 'cancel_booking'
    end
    member do
      put 'change_schedule'
    end
  end
  resources :passenger_details
end
