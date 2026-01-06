# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  # -------------------------------------------------
  # Admin / Internal Tools
  # -------------------------------------------------
  mount RailsAdmin::Engine => "/admin", as: "rails_admin"
  mount SimpleDiscussion::Engine => "/forum", constraints: -> { Flipper.enabled?(:forum) }

  require "sidekiq/web"

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
    mount Flipper::UI.app(Flipper) => "/flipper"
    mount MaintenanceTasks::Engine => "/maintenance_tasks"
  end

  mount Lookbook::Engine, at: "/lookbook" if Rails.env.development?

  # -------------------------------------------------
  # Devise & Authentication
  # -------------------------------------------------
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks",
    saml_sessions: "users/saml_sessions"
  }

  devise_scope :user do
    delete "/users/sign_out", to: "devise/sessions#destroy"
    get "/users/saml/sign_in", to: "users/saml_sessions#new"
    post "/users/saml/auth", to: "users/saml_sessions#create"
    get "/users/saml/metadata", to: "users/saml_sessions#metadata"
  end

  get "/users/edit", to: redirect("/")

  # -------------------------------------------------
  # Root & Static Pages
  # -------------------------------------------------
  root "circuitverse#index"
  get "/examples", to: "circuitverse#examples"
  get "/tos", to: "circuitverse#tos"
  get "/teachers", to: "circuitverse#teachers"
  get "/contribute", to: "circuitverse#contribute"
  get "/explore", to: "explore#index", as: :explore

  resources :about, only: :index
  resources :privacy, only: :index
  resources :announcements, except: :show

  # -------------------------------------------------
  # Error Pages
  # -------------------------------------------------
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unacceptable"
  get "/500", to: "errors#internal_error"

  # -------------------------------------------------
  # Groups & Assignments
  # -------------------------------------------------
  resources :groups, except: :index do
    resources :assignments, except: :index

    member do
      get "invite/:token", to: "groups#group_invite", as: :invite
      put :generate_token
    end
  end

  resources :group_members, only: %i[create update destroy]

  scope "/groups" do
    get "/:group_id/assignments/:id/reopen", to: "assignments#reopen"
    put "/:group_id/assignments/:id/close", to: "assignments#close"
    get "/:group_id/assignments/:id/start", to: "assignments#start"
  end

  # -------------------------------------------------
  # Grades
  # -------------------------------------------------
  scope "/grades" do
    post "/", to: "grades#create", as: :grades
    delete "/", to: "grades#destroy"
    get "/to_csv/:assignment_id", to: "grades#to_csv", as: :grades_to_csv
  end

  # -------------------------------------------------
  # Users
  # -------------------------------------------------
  scope "/users" do
    get "/:id/profile", to: redirect("/users/%{id}")
    get "/:id/profile/edit", to: "users/circuitverse#edit"
    patch "/:id/update", to: "users/circuitverse#update"
    get "/:id/groups", to: "users/circuitverse#groups"
    get "/:id", to: "users/circuitverse#index"
    get "/educational_institute/typeahead/:query",
        to: "users/circuitverse#typeahead_educational_institute"

    get "/:id/notifications", to: "users/noticed_notifications#index"
    patch "/:id/notifications/mark_all_as_read",
          to: "users/noticed_notifications#mark_all_as_read"
    post "/:id/notifications/mark_as_read/:notification_id",
         to: "users/noticed_notifications#mark_as_read"
  end

  # -------------------------------------------------
  # Projects
  # -------------------------------------------------
  scope "/projects" do
    post "/create_fork/:id", to: "projects#create_fork"
    get "/change_stars/:id", to: "projects#change_stars"
    get "/tags/:tag", to: redirect("/tags/%{tag}")
  end

  get "/tags/:tag", to: "tags#show", as: :tag

  # -------------------------------------------------
  # Simulator
  # -------------------------------------------------
  get "simulatorvue", to: "static#simulatorvue"
  get "simulatorvue/*path", to: "static#simulatorvue"

  scope "/simulator" do
    get "/", to: "simulator#new"
    get "/:id", to: "simulator#show"
    get "/edit/:id", to: "simulator#edit"
    get "/embed/:id", to: "simulator#embed"
    get "/get_data/:id", to: "simulator#get_data"
    post "/get_data", to: "simulator#get_data"
    post "/create_data", to: "simulator#create"
    post "/update_data", to: "simulator#update"
    post "/update_image", to: "simulator#update_image"
    post "/verilogcv", to: "simulator#verilog_cv"
    post "/post_issue", to: "simulator#post_issue"
    get "/issue_circuit_data/:id", to: "simulator#view_issue_circuit_data"
  end

  # -------------------------------------------------
  # Contests
  # -------------------------------------------------
  resources :contests, only: %i[index show] do
    member { get :leaderboard }

    resources :submissions, controller: "contests/submissions", only: %i[new create destroy] do
      member { post :withdraw }
      resources :votes, controller: "contests/submissions/votes", only: :create
    end
  end

  namespace :admin, path: "admins" do
    resources :contests, only: %i[index create update]
  end

  # -------------------------------------------------
  # API v1
  # -------------------------------------------------
  namespace :api do
    namespace :v1 do
      post "/auth/login", to: "authentication#login"
      post "/auth/signup", to: "authentication#signup"
      post "/oauth/login", to: "authentication#oauth_login"
      post "/oauth/signup", to: "authentication#oauth_signup"
      get "/public_key.pem", to: "authentication#public_key"

      resources :projects do
        member do
          get :image_preview
          get :circuit_data
          get :check_edit_access
          get "toggle-star", to: "projects#toggle_star"
          post :fork
        end
      end
    end
  end

  # -------------------------------------------------
  # Health Check
  # -------------------------------------------------
  get "/up", to: ->(_env) { [200, {}, [""]] }
end
# rubocop:enable Metrics/BlockLength
