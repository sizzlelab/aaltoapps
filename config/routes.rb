AaltoApps::Application.routes.draw do
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
    resources :ratings

    collection do
      namespace 'platform' do
        get ':platform' => 'products#by_platform'
      end
    end
  end

  resources :comments, :belongs_to => :products
  
  match ':controller(/:action(/:id))'
  root :to => "products#index"
end
