module HomeHelper

  BASE_ARTIST_FONT_SIZE = 12

  def artist_label(artist)
    out = ""

    checked = ""
    clazz = ""

    if artist.favourite?
      checked = "CHECKED"
      clazz = "favourite_artist"
    end
    
    out += "<label class='#{clazz}' onmousedown='this.toggleClassName(\"favourite_artist\");'>#{artist.name}"
    out += "<input type='checkbox' name='artist#{artist.id}' #{checked} style='display:none;' />"
    out += "</label>"
    
    return out
  end
  
  def rank_size_artist(artist, rank, i)
    out = ""
    name_size = (BASE_ARTIST_FONT_SIZE + (((rank / 100) - 1) * 3)).to_i
    height = name_size
    comma_size = name_size.to_f / 1.5

    out += "<span style='font-size:#{comma_size}px; line-height:#{height}px;'>"
    out += ", " if i > 0
    out += "</span> "
    out += "<strong>" if artist.favourite?
    out += "<span style='font-size:#{name_size}px; line-height:#{height}px;'>"
    out += "<a href='/last_fm_artist_page?artist_name=#{artist.name}' title='#{artist.name} on Last.fm'>"
    out += "#{artist.name}"
    out += "</a>"
    out += "</span>"
    out += "</strong>" if artist.favourite?
    return out
  end
end

