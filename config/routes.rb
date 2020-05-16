Rails.application.routes.draw do
  devise_for :users,
    controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  root to: "submissions#index"

  resources :submissions, only: [:index, :new, :create]
  resources :submissions, only: [:show], param: :short_id, path: :s
end
