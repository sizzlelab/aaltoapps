AaltoApps::Application.routes.draw do
  match '/users/login', :controller => "users", :action => "login"
  match '/users/logout', :controller => "users", :action => "logout"
  
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
