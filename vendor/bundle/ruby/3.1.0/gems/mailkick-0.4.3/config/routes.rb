Rails.application.routes.draw do
  unless respond_to?(:has_named_route?) && has_named_route?("mailkick")
    mount Mailkick::Engine => "/mailkick" if Mailkick.mount
  end
end

Mailkick::Engine.routes.draw do
  resources :subscriptions, only: [:show] do
    get :unsubscribe, on: :member
    get :subscribe, on: :member
  end
end
