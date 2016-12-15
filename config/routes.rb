Rails.application.routes.draw do
  scope 'tracklog' do
    root to: "dashboard#index", as: :dashboard

    match "login" => "auth#login", as: :login, via: [:get, :post]
    put "logout" => "auth#logout", as: :logout

    get "profile" => "profile#index",  as: :profile
    patch "profile" => "profile#update", as: :update_profile

    get "dashboard/activity_plots_data" => "dashboard#activity_plots_data"

    get "admin" => "admin#index", as: :admin

    get "tag/:tag" => "tags#show", as: :tag
    put "tag/:tag/add_viewer" => "tags#add_viewer", as: :add_tag_viewer
    delete "tag/:tag/delete_viewer" => "tags#delete_viewer", as: :delete_tag_viewer

    resources :logs do
      collection do
        get "year/:year" => :index, as: :year
        get "tag/:tag" => :tagged, as: :tagged
      end

      member do
        get :tracks
      end

      resources :tracks do
        resources :trackpoints

        member do
          match :transfer, via: [:get, :post]
          put "split/:trackpoint_id" => :split, as: :split
        end
      end
    end

    namespace :admin do
      resources :users
    end
  end
end
