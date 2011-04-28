class Subscription < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :token
  
  named_scope :for_watchers, lambda { |ids| {:conditions => {"user_id" => ids}}}

  def device_id
    device = APN::Device.find(:first, :conditions => {"token" => self.token})||{}
    return device[:id]
  end
end
