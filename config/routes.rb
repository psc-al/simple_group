Rails.application.routes.draw do
  devise_for :users,
    controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  root to: "submissions#index"

  namespace :inbox do
    resources :thread_reply_notifications, only: [:index, :update]
  end
  get "inbox", to: "inbox/thread_reply_notifications#index"

  resources :submissions, only: [:index, :new, :create]
  get "/submissions/:submission_action", to: "submissions#index", as: :marked_submissions
  resources :submissions, only: [:show], param: :short_id, path: :s do
    resources :comments, only: [:create]
  end

  resources :tags, only: [], path: :t do
    resources :submissions, only: [:index]
  end

  get "/pages/:page", to: "pages#show", as: :pages

  get "u/:username/submissions", to: "submissions#index", as: :user_submissions
  get "/u/:username/comments", to: "user_comments#index", as: :user_comments

  namespace :users do
    resource :submission_actions, only: [:update]
  end

  resources :user_invitations, only: [:create]

  namespace :admin do
    resources :comment_removals, only: [:index, :show, :new, :create, :destroy]
    resources :submission_removals, only: [:index, :show, :new, :create, :destroy]
    resources :tags, only: [:index, :new, :edit, :create, :update]
    resources :users, only: [:index, :show, :edit, :update]
  end

  post "/admin/users/:id/unban", to: "admin/users#unban", as: :admin_unban_user

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
