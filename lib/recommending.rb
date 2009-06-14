module Recommending
  
  SIMILARITY_THRESHOLD = 0
  RANK_THRESHOLD = 170
  MAX_TIME_BECAUSE_OF_HEROKU_TIMEOUT = 26 # don't allow requests longer than this other Heroku will cry
  
  def self.update_similar_artists(user)
    start_time = Time.new.tv_sec
    favourite_library_artists = user.favourite_library_artists
    for library_artist in favourite_library_artists
      similar_artists = Lastfming.get_similar_artists(library_artist)
      similar_artist_names = similar_artists.keys()
      for similar_artist_name in similar_artist_names
        SimilarArtist.get_or_create(similar_artist_name, user, library_artist, similar_artists[similar_artist_name]).save()
      end
      
      break if (Time.new.tv_sec - start_time) > MAX_TIME_BECAUSE_OF_HEROKU_TIMEOUT
    end
  end
  
  def self.library_ratio(recommendations, already_in_library)
    return already_in_library.length / (already_in_library.length + recommendations.length.to_f)
  end
  
  def self.favourite_artists_ratio(already_in_library)
    num_favourite_artists = 0
    already_in_library.keys.each { |artist_name| num_favourite_artists += 1 if already_in_library[artist_name].favourite? }
    return num_favourite_artists.to_f / already_in_library.length
  end
  
  def self.filter_by_rank(artists)
    return_artists = {}
    artists.keys.each { |artist_name| return_artists[artist_name] = artists[artist_name] if artists[artist_name].rank > RANK_THRESHOLD }
    return return_artists
  end
end