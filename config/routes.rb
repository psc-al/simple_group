Rails.application.routes.draw do
  devise_for :users,
    controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  root to: "submissions#index"

  resources :submissions, only: [:index, :new, :create]
  resources :submissions, only: [:show], param: :short_id, path: :s do
    resources :comments, only: [:create]
  end

  resources :tags, only: [], path: :t do
    resources :submissions, only: [:index]
  end

  namespace :users do
    resource :submission_actions, only: [:update]
  end

  namespace :api do
    namespace :v1 do
      resources :comments, only: [], param: :short_id do
        put :upvotes, action: :update, controller: "comments/upvotes"
        put :downvotes, action: :update, controller: "comments/downvotes"
      end

      resources :submissions, only: [], param: :short_id do
        put :upvotes, action: :update, controller: "submissions/upvotes"
        put :downvotes, action: :update, controller: "submissions/downvotes"
      end
    end
  end
end
