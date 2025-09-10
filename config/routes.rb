require "sidekiq/web"

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Sidekiq web interface (for development/monitoring)
  mount Sidekiq::Web => "/sidekiq" if Rails.env.development?

  # API routes
  namespace :api do
    namespace :v1 do
      resources :follows, only: %i[create destroy]
      resources :sleep_records, only: %i[index create] do
        collection do
          get :followed_users
        end
        member do
          patch :wake_up
        end
      end

      # User statistics
      resource :user_statistic, only: %i[show]
    end
  end
end
