AaltoApps::Application.routes.draw do
  match '/users/login', :controller => "users", :action => "login"
  
  resources :users do
    member do
      get 'login'
    end
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
