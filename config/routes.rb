Rails.application.routes.draw do
  get "vehicles/all", to: "vehicles#all", as: :all_vehicles

  resources :manufacturers do
    resources :vehicles do
      member do
        post :attach_images
        get :search_images
        post :attach_selected_images
        delete "images/:image_id", to: "vehicles#delete_image", as: :delete_image
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :manufacturers, only: [ :index, :show ]
      resources :vehicles, only: [ :index, :show ]

      namespace :toon do
        resources :manufacturers, only: [ :index, :show ]
        resources :vehicles, only: [ :index, :show ]
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
