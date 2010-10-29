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
  
  match ':controller(/:action(/:id))'
  root :to => "products#index"
end
