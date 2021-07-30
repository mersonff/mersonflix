Rails.application.routes.draw do

  resources :videos
  resources :categories do
    resources :videos, only: [:index]
  end

end
