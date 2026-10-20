Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get :dashboard, to: "users#dashboard", as: :dashboard # Creates /dashboard

  resources :items do
    patch :mark_as_bought, on: :member
    # creates a global action so the photo doesn't need a specific id. AI can see photo before it's saved.
    collection do
      post :analyze_photo
    end
  end

  resources :outfits do
    member do
      # DECISION: POST, not GET. GETs can be fired by prefetching/crawlers and must not spend money or write data.
      post :try_on
    end
    resources :messages, only: [:create] do
      member do
        post :confirm
        post :change_slot
      end
    end
  end

  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
