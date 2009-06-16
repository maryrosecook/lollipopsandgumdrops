class HomeController < ApplicationController

  def index
    if cookies[:user_id] && cookies[:user_id] != ""
    else
      redirect_to(:controller => 'user')
    end
  end

  def changes
    Githubing.update_commit_messages
    
    @commits = []
    prev_title = "woo woo yeah meep"
    for commit in Commit.get_latest_in_order
      @commits << commit if Util.ne(commit.title) && commit.title != prev_title # put a message AND haven't done multiple commits for single change
      prev_title = commit.title
    end
  end

  def library
    if cookies[:user_id]
      @user = User.find(cookies[:user_id])

      if params[:commit] == "Update library" || @user.library_artists.length == 0 # get all artists in user's library from lfm and save new ones
        Lastfming.get_library_artists(@user).each { |artist_name| LibraryArtist.get_or_create(artist_name, @user).save() }  
        redirect_to("/library")
      elsif params[:commit] == "Save" # updating favourite artists        
        favourited_bag = favourite(params) # favourite those ones that have been favourited in form
        unfavourite(@user, favourited_bag) # unfavourite artists who were unticked
        redirect_to("/library")
      else # just showing artists
      end
    else # no user set up so get user to pick one
      redirect_to("/")
    end
  end
  
  def recommendations
    if cookies[:user_id]
      @user = User.find(cookies[:user_id])

      if params[:show] || (@user.unsimilared_favourite_library_artists.length == 0 && @user.similar_artists.length > 0)  # show recommendations
        @recommendations = {}
        @already_in_library = {}

        library_artists = @user.library_artists
        library_artist_names = []
        library_artists.each { |library_artist| library_artist_names << library_artist.name }

        similar_artists = @user.recommended_similar_artists
        similar_artist_names = []
        similar_artists.each { |similar_artist| similar_artist_names << similar_artist.name }

        for similar_artist in similar_artists
          if library_artist_names.include?(similar_artist.name)
            integrate(@already_in_library, similar_artist)
          else
            integrate(@recommendations, similar_artist)
          end
        end

        array = Recommending.filter_out(@recommendations, @already_in_library)
        @recommendations = array[0]
        @already_in_library = array[1]
              
      elsif @user.similar_artists.length == 0 || @user.unsimilared_favourite_library_artists.length > 0 # get artists similar to favourited library artists not yet done
        Recommending.incremental_update_similar_artists(@user)
        @user.similar_artists.length > 0 ? redirect_to("/recommendations?show=yes") : @no_similar_artists = true
        
      elsif params[:commit] == "Update recommendations" # do complete refresh of similar_artists
        LibraryArtists.reset_similared(@user)
        redirect_to("/recommendations") # will redirect to clause above to update

      end
    end
  end
  
  private
    
    def favourite(params)
      favourited_bag = []
      for field_name in params.keys          
        if field_name =~ /artist[0-9]+/
          if library_artist_id = field_name.gsub(/artist/, "")
            if library_artist = LibraryArtist.find(library_artist_id)
              library_artist.favourite = 1
              library_artist.save()
              favourited_bag << library_artist
            end
          end
        end
      end
      
      return favourited_bag
    end
    
    def unfavourite(user, favourited_bag)
      for library_artist in user.library_artists
        if library_artist.favourite? && !favourited_bag.include?(library_artist)
          library_artist.favourite = 0
          if library_artist.save()
            library_artist.similar_artists.each { |favourited_artist| favourited_artist.destroy() }
          end
        end
      end
    end
    
    def integrate(artists, similar_artist)
      if !artists.has_key?(similar_artist.name)
        similar_artist.rank = similar_artist.similarity
        artists[similar_artist.name] = similar_artist
      end

      artists[similar_artist.name].rank += similar_artist.similarity
    end
end