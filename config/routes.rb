Rails.application.routes.draw do
  get "reports/index"
  get "reports/show"
  get "reports/create"
  #get "main/index"
  get "main/create"
  get "main/destroy"
  root 'main#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  get "generate_report", to: 'main#index', as: "generate_report", defaults: { format: :turbo_stream }
  get 'main/index', to: 'main#index', as: 'main_index'
  # Defines the root path route ("/")
  # root "posts#index"
end
