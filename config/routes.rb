Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  resources :videos
  resources :categories do
    resources :videos, only: [:index]
  end

end
