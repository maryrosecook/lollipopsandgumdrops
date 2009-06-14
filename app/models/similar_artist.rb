class SimilarArtist < ActiveRecord::Base
  belongs_to :library_artist
  belongs_to :user
  
  attr_accessor :rank
  
  def self.get_or_create(name, user, library_artist, similarity)
    similar_artist = find_for_name_user_similar(name, user, library_artist)
    if !similar_artist
      similar_artist = self.new
      similar_artist.name = name
      similar_artist.user_id = user.id
      similar_artist.library_artist_id = library_artist.id
      similar_artist.similarity = similarity
    end

    return similar_artist
  end
  
  def self.find_for_name_user_similar(name, user, library_artist)
    self.find(:first, :conditions =>  "user_id = #{user.id} 
                                       AND library_artist_id = #{library_artist.id}
                                       AND name = '#{Util.esc_apos(name)}' ")
  end
  
  def self.recommended_similar_artists(similar_artists)
    return_similar_artists = []
    similar_artists.each { |similar_artist| return_similar_artists << similar_artist if similar_artist.similarity > Recommending::SIMILARITY_THRESHOLD }
    return return_similar_artists
  end
  
  def favourite?
    favourite = false
    if library_artist = LibraryArtist.find_for_name_user(self.name, self.user)
      favourite = true if library_artist.favourite?
    end
    
    return favourite
  end
end