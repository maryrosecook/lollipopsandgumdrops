class Commit < ActiveRecord::Base

  LATEST = 20
  #create table commits(id INT(11) NOT NULL PRIMARY KEY AUTO_INCREMENT, git_id varchar(1000), title text);
  
  def self.new_from_feed(git_id, title)
    commit = self.new
    commit.git_id = git_id
    commit.title = title
    return commit
  end

  def self.find_for_git_id(git_id)
    self.find(:first, :conditions => "git_id = '#{git_id}'")
  end
  
  def self.latest
    self.find(:all, :order => 'id ASC', :limit => LATEST)
  end
end