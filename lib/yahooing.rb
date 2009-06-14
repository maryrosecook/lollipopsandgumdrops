module Yahooing
  
  DEFAULT_RUN_QUERY_SLEEP = 0
  
  def self.get_artist_myspace_url(artist_name)
    url = nil
    xml = self.run_query("'" + artist_name + "'" + " myspace", 1, nil)
    xml.elements.each('ResultSet/Result/Url') do |url_element|
      possible_url = url_element.text()
      url = possible_url if possible_url.match(/myspace/) # check url at least contains myspace
      break
    end
    
    url
  end
  
  YAHOO_API_ID = "eY9MvOzV34Ga_CrGgV0_xUFAj00htCAvEVdlsNM3CHURgZHz80fsFgbmnQwtohlRSYFe"
  def self.run_query(query, num_results, in_sleep_time)
    url = "http://search.yahooapis.com/WebSearchService/V1/webSearch?appid=#{YAHOO_API_ID}&query=#{query}&results=#{num_results}"
    body = APIUtil::get_request(url)
    in_sleep_time ? sleep_time = in_sleep_time : sleep_time = DEFAULT_RUN_QUERY_SLEEP
    sleep(sleep_time)
    xml = APIUtil::response_to_xml(body)
  end
end