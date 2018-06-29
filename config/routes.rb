Rails.application.routes.draw do
  get 'password_resets/new'

  get 'password_resets/edit'

  #get 'users/new'

	root 'static_pages#home'

  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'

  get '/signup', 	 to: 'users#new', as:'signup'

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  resources :users
  resources :account_activations, only: :edit
  #GET  http://ex.co/account_activation/<token>/edit  edit  edit_account_activation_url(token)
  #route provided looks like this^ (token === id)
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :microposts,          only: [:create, :destroy]

  get   '/microposts', to: 'static_pages#home' 
  #extra not to give error on reload after unsuccessful microposting
end