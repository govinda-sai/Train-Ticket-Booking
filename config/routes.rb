# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  resources :train_details do
    collection do
      get 'combination_search'
    end
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
    collection do
      get 'search'
    end
    collection do
      get 'combination_search'
    end
    collection do
      get 'search_by_train'
    end
    collection do
      get 'search_by_email'
    end
  end

  resources :passenger_details
end
