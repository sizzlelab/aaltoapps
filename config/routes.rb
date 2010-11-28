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
     get 'search'
      namespace 'platform' do
        get ':platform' => 'products#index'
      end
    end
  end
  #match 'products/platforms/:platform' => 'products#apps_by_platform',:as => :apps_by_platform
 
  #match 'products/:platform/:criteria' => 'products#apps_by_critea',:as => :apps_by_critea,:defaults=>{:platform=>"all platforms"}
  resources :comments, :belongs_to => :products
  
  match ':controller(/:action(/:id))'
  root :to => "products#index"
end
