Enetwork::Application.routes.draw do
  
  get 'hello_world', to: 'hello_world#index'
  namespace :api, defaults: {format: 'json'} do
    
    scope module: :v1000, constraints: ApiConstraints.new(version: 1000, default: true) do
      resources :sessions, only: [:create, :destroy] do
        post :create_anonymous, on: :collection
        post :authenticate_by_token, on: :collection
      end
      resources :users, only: [:create] do
        collection do
          get :profile
          put :profile
          put :update_avatar
          put :recover_password
          get :friends
          post :add_point_to_bag
          put :deactivate_point_in_bag
        end
      end
      resources :user_actions, only: [] do
        put :update_teaser
      end
      get 'sounds/:id/:version' => 'sounds#show' , as: :sound
      resources :reviews, only: [] do
        collection do
          get :init_review
          post :process_review
          match :load_points_being_reivewed, via: [:post, :get]
          get :load_points_of_lesson_for_previewing
          post :detect_linked_skills_of_example_and_mark_as_reminded
          match :reset_effectively_reviewed_times, via: [:put]
        end
      end
      resources :points, only: [:index, :create, :edit, :update, :destroy] do
        get :types, on: :collection
        get :search_including_variations, on: :collection
      end
      resources :app_logs, only: :create
      resources :friend_teasers, only: :index
      resources :device_keys, only: [:create]
      resources :lessons, only: :show
      resources :user_ui_actions, only: :create
      resources :opportunities, only: [] do
        put :ignore
        put :take
      end
    end
    
  end
  
  root :to => "main#index"
  get "html_convert" => "main#html_convert"
  get "test" => "main#test"
  get "react" => "main#react"
  
  get 'sounds/:id/:version' => 'sounds#show' , as: :sound
  
  if Rails.env.development?
    mount MailPreview => 'mail_view'
  end
  
end