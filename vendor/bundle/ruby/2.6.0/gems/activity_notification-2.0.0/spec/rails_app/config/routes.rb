Rails.application.routes.draw do
  root to: 'articles#index'
  devise_for :users
  resources :articles
  resources :comments, only: [:create, :destroy]

  notify_to :users, with_subscription: true
  notify_to :users, with_devise: :users, devise_default_routes: true, with_subscription: true

  notify_to :admins, with_devise: :users, with_subscription: true
  scope :admins, as: :admins do
    notify_to :admins, with_devise: :users, devise_default_routes: true, with_subscription: true, routing_scope: :admins
  end
end
