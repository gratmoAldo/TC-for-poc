class Subscription < ActiveRecord::Base

  VALID_NOTIFICATION_METHODS = ["apn","c2dm"]  

  belongs_to :user
  validates_uniqueness_of :display_id, :token
  belongs_to :service_request
  belongs_to :owner, :class_name => 'User', :foreign_key => 'created_by'
  validates_inclusion_of :notification_method, 
                          :in => VALID_NOTIFICATION_METHODS,
                          :allow_nil => false,
                          :message => "must be valid notification method"

  
  # before_save :validate_display_id
  
  named_scope :for_watchers, lambda { |ids| {:conditions => {"user_id" => ids}}}

# def validate_display_id
#   false
# end

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
