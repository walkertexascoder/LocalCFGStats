Rails.application.routes.draw do

  namespace :hq do
    resource :results, only: [:create]
  end

  namespace :leaderboards do
    resource :overall, only: [:create], controller: 'overall'
  end

  root 'home#index'

end
