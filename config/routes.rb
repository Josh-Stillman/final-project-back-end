Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'users/:id/matched', to: "users#matched_transactions"
  get 'users/:id/unmatched', to: "users#unmatched_transactions"
  get 'users/:id/businesses', to: "users#businesses"
  get 'users/:id/load_new_month', to: "users#load_new_month"
  get 'users/:id', to: "users#show"

  post '/login', to: 'authentication#create'
  post '/signup', to: 'users#create'
  get '/current_user', to: 'authentication#show'
end
