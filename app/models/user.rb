class User < ActiveRecord::Base
  has_many :library_artists
  
  LATEST = 10
  
  def self.new_from_request(username)
    user = self.new()
    user.username = username
    return user
  end
  
  def library_artists
    return LibraryArtist.find(:all, :conditions => "user_id = #{self.id}", :order => "created_at, id")
  end

  def favourite_library_artists
    return LibraryArtist.find(:all, :conditions => "user_id = #{self.id} AND favourite = 1 ", :order => "created_at, id")
  end
  
  def unsimilared_favourite_library_artists
    return LibraryArtist.find(:all, 
                              :conditions => "user_id = #{self.id} 
                                              AND favourite = 1 
                                              AND (similared IS NULL OR similared = 0) ", 
                              :order => "created_at, id")
  end
  
  def similar_artists
    similar_artists = []
    for favourite_library_artist in favourite_library_artists
      similar_artists += favourite_library_artist.similar_artists
    end
    
    return similar_artists
  end
  
  def recommended_similar_artists
    return SimilarArtist.recommended_similar_artists(self.similar_artists)
  end
  
  def self.latest
    return self.find(:all, :order => 'id DESC', :limit => LATEST)
  end
end