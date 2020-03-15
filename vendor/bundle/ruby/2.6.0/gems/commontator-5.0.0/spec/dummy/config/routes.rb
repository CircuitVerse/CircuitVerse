Rails.application.routes.draw do
  root to: 'dummy_models#show', id: 1

  resources :dummy_models, only: :show do
    get :hide, on: :member
  end

  mount Commontator::Engine => '/commontator'
end
