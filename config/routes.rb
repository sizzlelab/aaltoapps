AaltoApps::Application.routes.draw do
  resources :sessions
  resources :users do
    resources :products
    resources :comments
    resources :ratings
  end
  
  resources :products do
    resources :platforms
    resources :categories
    resources :comments
    resources :ratings
  end

  resources :comments, :belongs_to => :products
  
  match ':controller(/:action(/:id))'
  root :to => "products#index"
end
