Rails.application.routes.draw do
  resources :games
  resources :teams
  root to: 'welcome#index'
  resource :prediction, only: [:new, :create]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
