module Recommending
  
  SIMILARITY_THRESHOLD = 60
  
  def self.update_similar_artists(user)
    start_time = Time.new
    for library_artist in user.favourite_library_artists
      similar_artists = Lastfming.get_similar_artists(library_artist)
      for similar_artist_name in similar_artists.keys
        SimilarArtist.get_or_create(similar_artist_name, user, library_artist, similar_artists[similar_artist_name]).save()
      end
      
      break if (Time.new.tv_sec - start_time.tv_sec) > Util::MAX_SCRAPING_TIME_BECAUSE_OF_HEROKU_TIMEOUT
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
end