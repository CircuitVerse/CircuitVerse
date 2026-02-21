# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  mount SimpleDiscussion::Engine => "/forum", constraints: -> { Flipper.enabled?(:forum) }
  authenticate :user, ->(u) { u.admin? } do
    mount Avo::Engine, at: "/admin"
  end
  require "sidekiq/web"

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
    mount Flipper::UI.app(Flipper) => "/flipper"
    mount MaintenanceTasks::Engine => "/maintenance_tasks"
  end

  if Rails.env.development?
    mount Lookbook::Engine, at: "/lookbook"
  end

  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
    get '/users/saml/sign_in', to: 'users/saml_sessions#new'
    post '/users/saml/auth', to: 'users/saml_sessions#create'
    get '/users/saml/metadata', to: 'users/saml_sessions#metadata'
  end

  # resources :assignment_submissions
  resources :group_members, only: %i[create destroy update]
  resources :groups, except: %i[index] do
    resources :assignments, except: %i[index]
    member do
      get "invite/:token", to: "groups#group_invite", as: "invite"
      put :generate_token
    end
  end

  resources :custom_mails, except: %i[destroy]
  get "/custom_mails/send_mail/:id", to: "custom_mails#send_mail", as: "send_custom_mail"
  get "/custom_mails/send_mail_to_self/:id", to: "custom_mails#send_mail_self",
                                             as: "send_custom_mail_self"

  # grades
  scope "/grades" do
    post "/", to: "grades#create", as: "grades"
    delete "/", to: "grades#destroy"
    get "/to_csv/:assignment_id", to: "grades#to_csv", as: "grades_to_csv"
  end

  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_error"

  get "/search", to: "search#search"

  resources :about, only: :index
  resources :privacy, only: :index

  scope "/groups" do
    get "/:group_id/assignments/:id/reopen", to: "assignments#reopen", as: "reopen_group_assignment"
    put "/:group_id/assignments/:id/close", to: "assignments#close", as: "close_group_assignment"
    get "/:group_id/assignments/:id/start", to: "assignments#start", as: "assignment_start"
  end
  resources :stars, only: %i[create destroy]

  resources :featured_circuits, only: %i[index create]
  delete "/featured_circuits", to: "featured_circuits#destroy"

  get "/users/edit", to: redirect('/')
  devise_for :users, controllers: {
    registrations: "users/registrations", omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "users/sessions", :saml_sessions => "users/saml_sessions"
  }

  # Circuitverse web pages resources
  root "circuitverse#index"
  get  "/examples", to: "circuitverse#examples"
  get  "/tos", to: "circuitverse#tos"
  get  "/teachers", to: "circuitverse#teachers"
  get  "/contribute", to: "circuitverse#contribute"

  # Explore
  get "/explore", to: "explore#index", as: :explore

  #announcements
  resources :announcements, except: %i[show]

  # users

  scope "/users" do
    get "/:id/profile", to: redirect('/users/%{id}'), as: "profile"
    get "/:id/profile/edit", to: "users/circuitverse#edit", as: "profile_edit"
    patch "/:id/update", to: "users/circuitverse#update", as: "profile_update"
    get "/:id/groups", to: "users/circuitverse#groups", as: "user_groups"
    get "/:id/", to: "users/circuitverse#index", as: "user_projects"
    get "/educational_institute/typeahead/:query" => "users/circuitverse#typeahead_educational_institute"
    get "/:id/notifications", to: "users/noticed_notifications#index", as: "notifications"
    patch "/:id/notifications/mark_all_as_read", to: "users/noticed_notifications#mark_all_as_read", as: "mark_all_as_read"
    patch "/:id/notifications/read_all_notifications", to: "users/noticed_notifications#read_all_notifications", as: "read_all_notifications"
    post "/:id/notifications/mark_as_read/:notification_id", to: "users/noticed_notifications#mark_as_read", as: "mark_as_read"
  end

  post "/push/subscription/new", to: "push_subscription#create"
  post "/push/test", to: "push_subscription#test"

  # projects
  scope "/projects" do
    post "/create_fork/:id", to: "projects#create_fork", as: "create_fork_project"
    get "/change_stars/:id", to: "projects#change_stars", as: "change_stars"
    get "tags/:tag", to: redirect('/tags/%{tag}'), as: "legacy_tag"
  end

  get "/tags/:tag", to: "tags#show", as: "tag"

  resources :contests, only: %i[index show] do
    resources :submissions, only: %i[new create destroy], controller: "contests/submissions" do
      resources :votes, only: %i[create], controller: "contests/submissions/votes"
      member do
        post :withdraw, to: "contests/submissions#destroy"
      end
    end

      member do
        get :leaderboard
    end
  end

  namespace :admin, path: "admins" do
    resources :contests, only: %i[index create update]
  end

  # lti
  scope "lti"  do
    match 'launch', to: 'lti#launch', via: [:get, :post]
  end

  mount Commontator::Engine => "/commontator"

  # simulator
  scope "/simulator" do
    get "/:id", to: "simulator#show", as: "simulator"
    get "/edit/:id", to: "simulator#edit", as: "simulator_edit"
    post "/get_data", to: "simulator#get_data"
    get "get_data/:id", to: "simulator#get_data"
    post "/post_issue", to: "simulator#post_issue"
    get "/issue_circuit_data/:id", to: "simulator#view_issue_circuit_data"
    post "/update_data", to: "simulator#update"
    post "/update_image", to: "simulator#update_image"
    post "/create_data", to: "simulator#create"
    post "/verilogcv", to: "simulator#verilog_cv"
    get "/", to: "simulator#new", as: "simulator_new"
    get "/embed/:id", to: "simulator#embed", as: "simulator_embed"
  end

  scope "/testbench" do
    get "/", to: "testbench#creator", as: "testbench_creator"
  end
  # get 'simulator/embed_cross/:id', to: 'simulator#embed_cross', as: 'simulator_embed_cross'

  resources :users do
    resources :projects, except: %i[index new]
  end
  resources :collaborations, only: %i[create destroy update]

  # redirects
  get "/facebook", to: redirect("https://www.facebook.com/CircuitVerse")
  get "/twitter", to: redirect("https://www.twitter.com/CircuitVerse")
  get "/linkedin", to: redirect("https://www.linkedin.com/company/circuitverse")
  get "/youtube", to: redirect("https://www.youtube.com/@circuitverse4457")
  get "/slack", to: redirect(
    "https://join.slack.com/t/circuitverse-team/shared_invite/zt-3lv1zk5h1-xRhrjvQdUsYp1lAWVhuOrg"
  )
  get "/discord", to: redirect("https://discord.gg/8G6TpmM")
  get "/github", to: redirect("https://github.com/CircuitVerse")
  get "/learn", to: redirect("https://learn.circuitverse.org")
  get "/docs", to: redirect("https://docs.circuitverse.org")
  get "/features", to: redirect("/#home-features-section")

  # Health Check at /up ~> will be default in rails 7.1
  get '/up', to: ->(_env) { [200, {}, ['']] }

  # get 'comments/create_reply/:id', to: 'comments#create_reply', as: 'reply_comment'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      post "/auth/login", to: "authentication#login"
      post "/auth/signup", to: "authentication#signup"
      post "/oauth/login", to: "authentication#oauth_login"
      post "/oauth/signup", to: "authentication#oauth_signup"
      get  "/public_key.pem", to: "authentication#public_key"
      post "/password/forgot", to: "authentication#forgot_password"
      get "/notifications", to: "notifications#index"
      patch "/notifications/mark_as_read/:notification_id", to: "notifications#mark_as_read"
      patch "/notifications/mark_all_as_read", to: "notifications#mark_all_as_read"
      get "/me", to: "users#me"
      post "/forgot_password", to: "users#forgot_password"
      resources :users, only: %i[index show update]
      get "/projects/featured", to: "projects#featured_circuits"
      get "/projects/search", to: "projects#search"
      post "/simulator/post_issue", to: "simulator#post_issue"
      post "/simulator/verilogcv", to: "simulator#verilog_cv"
      resources :projects, only: %i[index show create update destroy] do
        collection do
          patch :update_circuit, path: "update_circuit"
        end
        member do
          get "toggle-star", to: "projects#toggle_star"
          post "fork", to: "projects#create_fork"
          get "image_preview", to: "projects#image_preview"
          get :circuit_data
          get :check_edit_access
        end
        resources :collaborators, only: %i[index create destroy]
      end
      resources :users do
        member do
          get "projects", to: "projects#user_projects"
          get "favourites", to: "projects#user_favourites"
          # get "projects/all", to: "projects#all_user_projects"
        end
      end
      post "/assignments/:assignment_id/projects/:project_id/grades", to: "grades#create"
      resources :grades, only: %i[update destroy]
      get "/groups/owned", to: "groups#groups_owned"
      resources :groups, only: %i[index show update destroy]
      delete "/group/members/:id", to: "group_members#destroy"
      put "/group/members/:id", to: "group_members#update"
      patch "/group/members/:id", to: "group_members#update"
      resources :groups do
        resources :members, controller: "group_members", shallow: true, only: %i[index create]
        resources :assignments, shallow: true
      end
      resources :assignments do
        member do
          patch "reopen"
          patch "start"
        end
      end
      resources :threads do
        resources :comments, only: %i[index create update], shallow: true do
          member do
            put "upvote"
            put "downvote"
            put "unvote"

            put "delete"
            put "undelete"
          end
        end

        member do
          put "close"
          put "reopen"

          put "subscribe"
          put "unsubscribe"
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
