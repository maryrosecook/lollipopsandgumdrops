module HomeHelper

  BASE_ARTIST_FONT_SIZE = 12
  COMMA_DEEMPHASIZE_AMOUNT = 1.2

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
  
  def rank_size_artist(artist, max_rank, min_rank, rank, i)
    out = ""
    
    max_px_add = 20
    max_px_add_proportion = ((rank - min_rank) / (max_rank - min_rank))
    add = (max_px_add * max_px_add_proportion).to_i
    
    name_size = BASE_ARTIST_FONT_SIZE + add
    height = name_size + 3
    comma_size = name_size.to_f / COMMA_DEEMPHASIZE_AMOUNT

    out += "<span style='font-size:#{comma_size}px; line-height:#{height}px;'>"
    out += ", " if i > 0
    out += "</span> "
    out += "<strong>" if artist.favourite?
    out += "<span style='font-size:#{name_size}px; line-height:#{height}px;'>"
    out += "<a href=\"/elsewhere/myspace/#{artist.name}\" title='#{artist.name} on Myspace'>"
    out += "#{artist.name}"
    out += "</a>"
    out += "</span>"
    out += "</strong>" if artist.favourite?
    return out
  end
end

