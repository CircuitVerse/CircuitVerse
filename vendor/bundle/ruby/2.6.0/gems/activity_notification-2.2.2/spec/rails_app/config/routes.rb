Rails.application.routes.draw do
  # Routes for example Rails application
  root to: 'articles#index'
  devise_for :users
  resources :articles, except: [:destroy]
  resources :comments, only: [:create, :destroy]

  # activity_notification routes for users
  notify_to :users, with_subscription: true
  notify_to :users, with_devise: :users, devise_default_routes: true, with_subscription: true

  # activity_notification routes for admins
  notify_to :admins, with_devise: :users, with_subscription: true
  scope :admins, as: :admins do
    notify_to :admins, with_devise: :users, devise_default_routes: true, with_subscription: true, routing_scope: :admins
  end

  # Routes for single page application working with activity_notification REST API backend
  resources :spa, only: [:index]
  namespace :api do
    scope :"v#{ActivityNotification::GEM_VERSION::MAJOR}" do
      mount_devise_token_auth_for 'User', at: 'auth'
    end
  end

  # Routes of activity_notification REST API backend for users
  scope :api do
    scope :"v#{ActivityNotification::GEM_VERSION::MAJOR}" do
      notify_to :users, api_mode: true, with_subscription: true
      notify_to :users, api_mode: true, with_devise: :users, devise_default_routes: true, with_subscription: true
      resources :apidocs, only: [:index], controller: 'activity_notification/apidocs'
      resources :users, only: [:index, :show] do
        collection do
          get :find
        end
      end
    end
  end

  # Routes of activity_notification REST API backend for admins
  scope :api do
    scope :"v#{ActivityNotification::GEM_VERSION::MAJOR}" do
      notify_to :admins, api_mode: true, with_devise: :users, with_subscription: true
      scope :admins, as: :admins do
        notify_to :admins, api_mode: true, with_devise: :users, devise_default_routes: true, with_subscription: true
      end
      resources :admins, only: [:index, :show]
    end
  end
end
