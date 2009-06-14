module APIUtil

  # gets xml from passed url
  def self.get_request(url)
    response = nil
    url = make_url_safe(url)
    begin
      Timeout::timeout(2) do
        resp = Net::HTTP.get_response(URI.parse(url)) # get_response takes an URI object
        response = resp.body
      end
    rescue Timeout::Error
    rescue
    end
  
    response
  end
  
  def self.safely_parse_url(url)
    parsed_url = nil
    safer_url = APIUtil::make_url_safe(url)
    begin
      parsed_url = URI::parse(safer_url)
    rescue # failure
    end
    
    parsed_url
  end
  
  def self.make_url_safe(url)
    url.strip.gsub(/\s/, "%20")
  end
  
  def self.response_to_xml(body)
    xml = REXML::Document.new(body)
  end

  def self.simple_extract_tag_data(res, tag)
    tag_data = nil
    if res
      if xmlDoc = response_to_xml(res)
        if xmlDoc.elements[tag]
          tag_data = xmlDoc.elements[tag].text
        end
      end
    end
    
    tag_data
  end
end