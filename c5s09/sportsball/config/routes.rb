Rails.application.routes.draw do
  resources :games
  resources :teams
  root to: 'welcome#index'
  resource :prediction, only: [:new, :create]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
