class HomeController < ApplicationController

  def index
    if cookies[:user_id] && cookies[:user_id] != ""
    else
      redirect_to(:controller => 'user')
    end
  end

  def library
    if cookies[:user_id]
      @user = User.find(cookies[:user_id])

      if params[:commit] == "Update library" || @user.library_artists.length == 0 # get all artists in user's library from lfm and save new ones
        for artist_name in Lastfming.get_library_artists(@user)
          LibraryArtist.get_or_create(artist_name, @user).save()
        end
        
        redirect_to("/library")
      elsif params[:commit] == "Save" # updating favourite artists
        favourited_bag = []
        
        # favourite those ones that have been favourited in form
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

        # unfavourite artists who were unticked
        for library_artist in @user.library_artists
          if library_artist.favourite? && !favourited_bag.include?(library_artist)
            library_artist.favourite = 0
            if library_artist.save()
              library_artist.similar_artists.each { |favourited_artist| favourited_artist.destroy() }
            end
          end
        end

        #save_bag.each { |library_artist| library_artist.save() }
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
      if params[:commit] == "Update recommendations" || @user.similar_artists.length == 0 # pull in artists similar to library artists
        Recommending.update_similar_artists(@user)
        if @user.similar_artists.length > 0
          redirect_to("/recommendations")
        else
          @no_similar_artists = true
        end
      else # show recommendations
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
            if !@already_in_library.has_key?(similar_artist.name)
              similar_artist.rank = similar_artist.similarity
              @already_in_library[similar_artist.name] = similar_artist
            end
            @already_in_library[similar_artist.name].rank += similar_artist.similarity
          else
            if !@recommendations.has_key?(similar_artist.name)
              similar_artist.rank = similar_artist.similarity
              @recommendations[similar_artist.name] = similar_artist
            end
            @recommendations[similar_artist.name].rank += similar_artist.similarity
          end
        end
      end
    end
  end
  
  def last_fm_artist_page
    redirect_url = "/recommendations"
    if Util.ne(params[:artist_name])
      if last_fm_url = Lastfming::get_artist_url(params[:artist_name])
        redirect_url = last_fm_url
      end
    end
    
    redirect_to(redirect_url)
  end
end