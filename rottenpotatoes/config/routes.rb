Rottenpotatoes::Application.routes.draw do
  devise_for :moviegoers, controllers:{
    sessions: 'moviegoers/sessions',
    omniauth_callbacks: 'moviegoers/omniauth_callbacks'
  }
  devise_scope :moviegoer do
    root to: "devise/sessions#new"
  end
  resources :movies
  # map '/' to be a redirect to '/movies'
  post '/movies/search_tmdb' => 'movies#search_tmdb', :as => 'search_tmdb'
end
