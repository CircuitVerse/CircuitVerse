Rails.application.routes.draw do
  resources :collaborations
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # resources :assignment_submissions
  resources :group_members ,only: [:create,:destroy]
  resources :groups do
    resources :assignments
  end

  scope '/groups' do
    get '/:id/assignments/WYSIWYG/index.css', to: redirect('/index.css')
    get '/:id/assignments/WYSIWYG/bootstrap-wysiwyg.js', to: redirect('/bootstrap-wysiwyg.js')
    get '/:id/assignments/:id/WYSIWYG/index.css', to: redirect('/index.css')      # in case of editing
    get '/:id/assignments/:id/WYSIWYG/bootstrap-wysiwyg.js', to: redirect('/bootstrap-wysiwyg.js')   # in case of editing
    get '/:group_id/assignments/:id/reopen', to: 'assignments#reopen', as: 'reopen_group_assignment'
    get '/:group_id/assignments/:id/start', to: 'assignments#start', as: 'assignment_start'
  end
  resources :stars , only: [:create, :destroy]


  devise_for :users, controllers: {registrations: 'users/registrations', :omniauth_callbacks => "users/omniauth_callbacks"}


  #Logix web pages resources
  root 'logix#index'
  get  '/gettingStarted', to:'logix#gettingStarted'
  get  '/examples', to:'logix#examples'
  get  '/features', to:'logix#features'
  get  '/about', to:'logix#about'
  get  '/privacy', to:'logix#privacy'
  get  '/tos', to:'logix#tos'
  get  '/search', to:'logix#search'
  get  '/teachers', to:'logix#teachers'
  get  '/contribute', to:'logix#contribute'

  #users
  scope '/users' do
    get '/', to: 'welcome#all_user_index', as: 'all_users'
    get '/:id/profile', to: 'users/logix#profile', as: 'profile'
    get '/:id/profile/edit', to: 'users/logix#edit', as: 'profile_edit'
    patch '/:id/update', to: 'users/logix#update', as: 'profile_update'
    get '/:id/groups', to: 'users/logix#groups', as: 'user_groups'
    get '/:id/', to: 'users/logix#index', as: 'user_projects'
    get '/:id/favourites', to: 'users/logix#favourites', as: 'user_favourites'
    get '/:id/projects/:id/WYSIWYG/index.css', to: redirect('/index.css')
    get '/:id/projects/:id/WYSIWYG/bootstrap-wysiwyg.js', to: redirect('/bootstrap-wysiwyg.js')
    get '/educational_institute/typeahead/:query' => 'users/logix#typeahead_educational_institute'
  end


  #projects
  get 'projects/create_fork/:id', to: 'projects#create_fork',as: 'create_fork_project'
  get 'projects/change_stars/:id', to: 'projects#change_stars', as: 'change_stars'

  mount Commontator::Engine => '/commontator'

  #simulator
  scope '/simulator' do
    get '/:id', to: 'simulator#show', as: 'simulator'
    get '/edit/:id', to: 'simulator#edit', as: 'simulator_edit'
    post '/get_data', to: 'simulator#get_data'
    post '/update_data', to: 'simulator#update'
    post '/update_image', to: 'simulator#update_image'
    post '/create_data', to: 'simulator#create'
    get '/', to: 'simulator#new', as: 'simulator_new'
    get '/embed/:id', to: 'simulator#embed', as: 'simulator_embed'
  end
  # get 'simulator/embed_cross/:id', to: 'simulator#embed_cross', as: 'simulator_embed_cross'


  resources :users do
    resources :projects, only: [:show, :edit, :update, :new, :create, :destroy]
  end




  # get 'comments/create_reply/:id', to: 'comments#create_reply', as: 'reply_comment'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
