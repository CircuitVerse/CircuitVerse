DummyApp::Application.routes.draw do
  match 'comments' => 'comments#create', :via => [:put]
  match 'say' => 'comments#say', :via => [:get]
  resources :comments
  match 'prepended' => 'prepended#show', :via => [:get]
  root :to => "comments#index"
end
