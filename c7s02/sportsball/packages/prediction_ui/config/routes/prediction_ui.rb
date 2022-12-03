
Rails.application.routes.draw do
  resource :prediction, only: [:new, :create]
end

