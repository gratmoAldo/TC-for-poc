class Subscription < ActiveRecord::Base
  belongs_to :user
  validates_uniqueness_of :display_id
  
  named_scope :for_watchers, lambda { |ids| {:conditions => {"user_id" => ids}}}

  def device
    default_device = {:id=>nil}
    case notification_method.to_sym
    when :apn
      APN::Device.find(:first, :conditions => {"token" => self.display_id})||default_device
    when :c2dm
      C2dm::Device.find(:first, :conditions => {"registration_id" => self.display_id})||default_device
    else
      default_device
    end
  end
end
