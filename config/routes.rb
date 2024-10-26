require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do

  # Only allow admin to access Sidekiq dashboard
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }

  root to: "home#index"

end
