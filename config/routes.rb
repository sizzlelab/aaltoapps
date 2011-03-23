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

		put :block
		put :approve
   
    collection do
      namespace 'platform' do
        get ':platform' => 'products#index'
      end
    end
  end

  resources :comments, :belongs_to => :products
  
  root :to => "products#mainpage"
  match ':controller(/:action(/:id))'
end
