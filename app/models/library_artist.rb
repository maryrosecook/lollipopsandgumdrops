class LibraryArtist < ActiveRecord::Base
  belongs_to :user
  has_many :similar_artists
  
  attr_accessor :rank
  
  def self.get_or_create(name, user)
    artist = find_for_name_user(name, user)
    if !artist
      artist = self.new
      artist.name = name
      artist.user_id = user.id
    end

    return artist
  end
  
  def self.find_for_name_user(name, user)
    self.find(:first, :conditions =>  "name = '#{Util.esc_apos(name)}' AND user_id = #{user.id}")
  end
  
  def favourite?
    return self.favourite == 1
  end
end