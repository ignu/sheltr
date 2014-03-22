Sheltr::Application.routes.draw do
  resources :locations
  root 'home#index'
end
