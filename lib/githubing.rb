require 'rubygems'
require 'hpricot'
require 'open-uri'

module Githubing
  
  COMMIT_FEED = "http://github.com/feeds/maryrosecook/commits/lollipopsandgumdrops/master"
  
  def self.update_commit_messages()
    url = safely_parse_url(COMMIT_FEED)
    doc = open(url.to_s) do |f|
      Hpricot.XML(f)
    end

    (doc.at("feed")/:"entry").each do |entry|
      commit_message = {}
      git_id = entry.at("id").inner_html
      if !Commit.find_for_git_id(git_id)
        title = entry.at("title").inner_html
        updated = entry.at("updated").inner_html
        if commit = Commit.new_from_feed(git_id, title)
          commit.save
        end
      end
    end
  end

  private

    def self.safely_parse_url(url)
      parsed_url = nil
      begin
        parsed_url = URI::parse(make_url_safe(url))
      rescue # failure
      end
    
      return parsed_url
    end
  
    def self.make_url_safe(url)
      url.strip.gsub(/\s/, "%20")
    end
end