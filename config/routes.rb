Rails.application.routes.draw do

  resource :results, only: [:create]

  root 'home#index'

end
