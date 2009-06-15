module Recommending
  
  SIMILARITY_THRESHOLD = 0
  
  MAX_ARTISTS = 40
  FILTER_METHOD = "filter_by_rank"
  
  MAX_TIME_BECAUSE_OF_HEROKU_TIMEOUT = 24 # don't allow requests longer than this other Heroku will cry
  
  def self.library_ratio(recommendations, already_in_library)
    return already_in_library.length / (already_in_library.length + recommendations.length.to_f)
  end
  
  def self.favourite_artists_ratio(already_in_library)
    num_favourite_artists = 0
    already_in_library.keys.each { |artist_name| num_favourite_artists += 1 if already_in_library[artist_name].favourite? }
    return num_favourite_artists.to_f / already_in_library.length
  end
  
  def self.filter_out(recommendations, already_in_library)
    if recommendations.length > 0 && already_in_library.length > 0
      recommendations = filter_out_lower_orders(recommendations, MAX_ARTISTS)
      recommended_artist_names = recommendations.keys.sort { |x,y| recommendations[y].rank <=> recommendations[x].rank }
      lowest_rank = recommendations[recommended_artist_names.last].rank
      already_in_library = filter_by_rank(already_in_library, lowest_rank)
    end

    return [recommendations, already_in_library]
  end
  
  def self.incremental_update_similar_artists(user)
    get_similar_artists(user, user.unsimilared_favourite_library_artists)
  end
  
  def self.complete_update_similar_artists(user)
    get_similar_artists(user, user.favourite_library_artists)
  end
  
  private
  
    def self.filter_by_rank(artists, rank)
      return_artists = {}
      artists.keys.each { |artist_name| return_artists[artist_name] = artists[artist_name] if artists[artist_name].rank > rank }
      return return_artists
    end

    def self.filter_out_lower_orders(artists, num_to_keep)
      return_artists = {}
      artist_names = artists.keys.sort { |x,y| artists[y].rank <=> artists[x].rank }
      for i in (0..Util.min(artist_names.length, num_to_keep)-1)
        artist_name = artist_names[i]
        artist = artists[artist_name]
        return_artists[artist_name] = artist
      end

      return return_artists
    end
  
    def self.get_similar_artists(user, special_library_artists)
      start_time = Time.new.tv_sec
      for library_artist in special_library_artists
        similar_artists = Lastfming.get_similar_artists(library_artist)
        similar_artist_names = similar_artists.keys()
        for similar_artist_name in similar_artist_names
          SimilarArtist.get_or_create(similar_artist_name, user, library_artist, similar_artists[similar_artist_name]).save()
        end

        library_artist.similared = 1
        library_artist.save
        break if (Time.new.tv_sec - start_time) > MAX_TIME_BECAUSE_OF_HEROKU_TIMEOUT
      end

    end
end