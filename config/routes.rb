require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do

  # Only allow admin to access Sidekiq dashboard
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  authenticated :user do
    root 'dashboard#index', as: :authenticated_root
  end

  root 'home#index'

  resources :loans do
    member do
      patch :approve
      patch :reject
      patch :accept_with_adjustment
      patch :accept_adjustment
      patch :request_readjustment
      patch :repay
      patch :open_loan
      patch :close_loan
      get :transaction_history
    end
    collection do
      get :admin_index
      get :active_loans
    end
  end

  resources :wallets, only: [:show]

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }



end
