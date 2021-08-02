Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  get '/videos/free', to: 'videos#list_free'

  resources :videos do
  end
  resources :categories do
    resources :videos, only: [:index]
  end


end
