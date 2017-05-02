Rails.application.routes.draw do
  scope :api do
    get '/resource/error_message.js', to: 'resource#error_message'

    resource :user, controller: :user, only: [:show]
    resources :calendars, only: [:index] do
      resources :events, only: [:index]
    end
  end

  scope controller: :omniauth, as: :omniauth, path: :omniauth do
    get :google_redirect
  end

  scope controller: :omniauth, as: :line, path: :line do
    get :callback, action: :line_callback
    post :callback, action: :line_callback
  end

  devise_for :users, controllers: {
    omniauth_callbacks: "omniauth"
  }
end
