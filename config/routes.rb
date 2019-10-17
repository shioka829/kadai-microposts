Rails.application.routes.draw do
    root to: 'toppages#index'
    
    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    delete 'logout', to: 'sessions#destroy'
    
    get 'signup', to: 'users#new'
    resources :users, only: [:index, :show, :new, :create] do
      member do
        get :followings #フォローしているユーザ一覧
        get :followers #フォローされているユーザ一覧
        get :likes #お気に入り投稿一覧
      end
    end
    
    resources :microposts, only: [:create, :destroy]
    resources :relationships, only: [:create, :destroy]
    resources :favorites, only: [:create, :destroy]
end
