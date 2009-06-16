class Commit < ActiveRecord::Base

  LATEST = 20

  def self.new_from_feed(git_id, title)
    commit = self.new
    commit.git_id = git_id
    commit.title = title
    return commit
  end

  def self.find_for_git_id(git_id)
    self.find(:first, :conditions => "git_id = '#{git_id}'")
  end
  
  def self.get_latest_in_order
    self.find(:all, :order => 'id ASC', :limit => LATEST)
  end
end