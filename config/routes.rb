AaltoApps::Application.routes.draw do
  # prefix all urls with language (e.g. /en/rest_of_url)
  filter :locale

  resources :sessions
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

  root :to => "products#mainpage"
  match ':controller(/:action(/:id))'
end
