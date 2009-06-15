module Util

  def self.ne(str)
    str && str != ""
  end
  
  def self.strip_html(str)
    str.gsub(/<\/?[^>]*>/, "")
  end
  
  def self.esc_speech(str)
    str = str.gsub(/"/, '\"')
  end
  
  def self.esc_apos(str)
    return_str = str
    return_str = return_str.gsub(/'/, "\\\\'")
    return return_str
  end
  
  def self.min(a,b)
    min = nil
    b < a ? min = b : min = a
    return min
  end
  
  def self.max(a,b)
    max = nil
    b > a ? max = b : max = a
    return max
  end
  
  # shorts passed str to passed word_count
  def self.truncate(str, word_count, elipsis)
    words = str.split()
    truncated_str = str.split[0..(word_count-1)].join(" ")
    if elipsis && words.length() > word_count
      truncated_str += "..."
    end
    
    truncated_str
  end
  
  # returns random element of array
  def self.rand_el(array)
    el = nil
    el = array[rand()*(array.length-1)] unless !array || array.length < 1
    
    el
  end
  
  def self.scrub_fastidious_entities(str)
    str.gsub(/&#8217;/, "'").gsub(/&amp;/, "&")
  end
  
  def self.parse_js_response(request)
    word_raw = request.raw_post || request.query_string
    word_raw = word_raw.gsub(/(.*)authenticity_token.*/, "\\1")
    word_raw.gsub(/&/, "")
  end
  
  def self.items_occurring_more_than_once(items)
    ret_items_occurring_more_than_once = []
    for item_a in items
      occurrences = 0
      items.each {|item_b| occurrences += 1 if item_a == item_b }
      ret_items_occurring_more_than_once << item_a if occurrences > 1
    end
    
    ret_items_occurring_more_than_once.uniq()
  end
end