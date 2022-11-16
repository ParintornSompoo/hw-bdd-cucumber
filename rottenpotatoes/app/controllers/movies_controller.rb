require 'uri'
require 'net/http'
require 'json'

# MoviesController is responsible for feature associate with movie data
class MoviesController < ApplicationController
  
  # Display movie data via movieID params
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  # Display index page with movies data table with checkbox feature
  def index
    sort = params[:sort] || session[:sort]
    case sort
    when 'title'
      ordering,@title_header = {:title => :asc}, 'bg-warning hilite'
    when 'release_date'
      ordering,@date_header = {:release_date => :asc}, 'bg-warning hilite'
    end
    @selected_ratings = params[:ratings] || session[:ratings] || Hash[Movie.all_ratings.map {|rating| [rating, rating]}]
    if params[:sort] != session[:sort] or params[:ratings] != session[:ratings]
      session[:sort] = sort
      session[:ratings] = @selected_ratings
      redirect_to :sort => sort, :ratings => @selected_ratings and return
    end
    @movies = Movie.where(rating: @selected_ratings.keys).order(ordering)
  end

  # Display new template
  def new
    # default: render 'new' template
  end

  # Create data to Movie table
  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  # Get movie data via movie id
  def edit
    @movie = Movie.find params[:id]
  end

  # Update movie data specify via movie id
  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  # Delete movie row via movie id
  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  # Call TMDB API for movie data
  def tmdb_search_movie(movie_title)
    api_key = "fbc366092c54ff98967f908e634acd23"
    uri = URI("https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&language=en-US&query=#{movie_title}&page=1&include_adult=false")
    res = Net::HTTP.get_response(uri)
    tmdb_results = JSON.parse(res.body)['results']
    tmdb_results
  end

  # Get movie data via title through TMDb api
  def search_tmdb
    title = params[:search_terms][:title]
    results = self.tmdb_search_movie(title)
    if results.length() == 0 #Sad path (no result found)
      flash[:notice] = "'Movie That Does Not Exist' was not found in TMDb."
      redirect_to movies_path
      return
    else
      item = results[0] #first result
      @movies = {
        "title" => item["title"],
        "release_date" => item["release_date"]
      }
      return
    end
  end

end
