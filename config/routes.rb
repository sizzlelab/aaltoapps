AaltoApps::Application.routes.draw do
  # prefix all urls with language (e.g. /en/rest_of_url)
  filter :locale

  get 'session' => 'sessions#index' # login page
  post 'session' => 'sessions#create'
  get 'session/cas' => 'sessions#create', :cas => true, :as => :cas_session
  delete 'session' => 'sessions#destroy'

  resources :users do
    resources :products
    resources :comments
    resources :ratings
  end
  
  resources :platforms do
    resources :products
  end
  
  resources :products do
    resources :platforms
    resources :comments
    resources :downloads
    resources :ratings

    member do
      put :block
      put :approve
      put :request_approval
      put :promote
      put :demote
    end

    collection do
      namespace 'platform' do
        get ':platform' => 'products#index'
      end

      get 'tag/:tags' => 'products#index', :as => :tag

      get :autocomplete_tags
    end
  end

  resources :comments, :belongs_to => :products

  resources :pages, :only => :show

  # Receives proxy-granting ticket from CAS server.
  # This must be called using HTTPS or from localhost for security reasons.
  get 'receive_pgt' => 'cas_proxy_callback#receive_pgt'
  # used internally for retrieving PGTs
  get 'retrieve_pgt' => 'cas_proxy_callback#retrieve_pgt'

  root :to => "products#mainpage"

  # if no other routes match, render error page
  match '*path' => ApplicationController.action(:render_404)
end
