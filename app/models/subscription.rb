class Subscription < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :token
  
  named_scope :for_watchers, lambda { |ids| {:conditions => {"user_id" => ids}}}
  
end
