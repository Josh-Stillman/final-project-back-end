Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'users/matched', to: "users#matched_transactions"
  get 'users/unmatched', to: "users#unmatched_transactions"
end
