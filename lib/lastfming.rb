require 'rubygems'
require 'hpricot'
require 'open-uri'

module Lastfming
  
  MAX_TIME_BECAUSE_OF_HEROKU_TIMEOUT = 16 # don't allow requests longer than this other Heroku will cry
  
  LAST_FM_API_KEY = "0fe92bb2a3b1e5b714cc39e2df8da14f"
  def self.get_library_artists(user)
    library_artists = []

    page = 1
    if user
      # figure out number of pages of artists
      page_count = 0
      url = APIUtil.safely_parse_url("http://ws.audioscrobbler.com/2.0/?method=library.getartists&api_key=#{LAST_FM_API_KEY}&user=#{user.username}&page=#{page}")
      doc = open(url.to_s) do |f|
        Hpricot.XML(f)
      end

      if xml_data = doc.at("lfm/artists")
        page_count = xml_data.attributes["totalPages"].to_i
        page_count = 1 if page_count == 0 # weird last.fm bug where users w/ 1 page of library are said to have 0 pages of library
      end

      start_time = Time.new
      while page <= page_count
        url = APIUtil.safely_parse_url("http://ws.audioscrobbler.com/2.0/?method=library.getartists&api_key=#{LAST_FM_API_KEY}&user=#{user.username}&page=#{page}")
        doc = open(url.to_s) do |f|
          Hpricot.XML(f)
        end

        # add artist names to array
        (doc.at("lfm/artists")/:"artist").each do |artist_data|
          library_artists << artist_data.at("name").inner_html
        end
        
        page += 1
        
        # avoid bullshit heroku request timeout
        break if (Time.new.tv_sec - start_time.tv_sec) > MAX_TIME_BECAUSE_OF_HEROKU_TIMEOUT
      end
    end
    
    return library_artists
  end
  
  
  
  def self.get_similar_artists(library_artist)
    similar_artists = {}
    
    if url = APIUtil.safely_parse_url("http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&artist=#{library_artist.name}&api_key=#{LAST_FM_API_KEY}")
      doc = open(url.to_s) do |f|
        Hpricot.XML(f)
      end
    
      (doc.at("lfm/similarartists")/:"artist").each do |artist_data|
        similar_artists[artist_data.at("name").inner_html] = artist_data.at("match").inner_html
      end
    end
    
    return similar_artists
  end
  
  def self.get_artist_url(artist)
    APIUtil::simple_extract_tag_data(Lastfming::artist_get_info(artist), "lfm/artist/url")
  end
  
  def self.artist_get_info(artist)
    url = "http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&api_key=#{LAST_FM_API_KEY}&artist=#{artist}"
    return APIUtil::get_request(url)
  end
end