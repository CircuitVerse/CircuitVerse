DummyApp::Application.routes.draw do
  match 'comments' => 'comments#create', :via => [:put]
  match 'say' => 'comments#say', :via => [:get]
  resources :comments
  root :to => "comments#index"
end
