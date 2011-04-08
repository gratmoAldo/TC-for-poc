class Inbox < ActiveRecord::Base

  has_many :inbox_srs, :dependent => :destroy
  has_many :service_requests, :through => :inbox_srs
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  
  # def to_json(noarg=nil)
    # {:name => name, :owner_name => owner.fullname, :owner_id => owner.id}.to_json
  # end

end
