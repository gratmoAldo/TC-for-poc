class ServiceRequest < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :contact, :class_name => 'User', :foreign_key => 'contact_id'
  belongs_to :escalation
  after_save :notify_owner
  
  def notify_owner

# TODO should look at all users who have the SR in their inbox
    # subscription = Subscription.find(:all, :conditions => ["user_id = ? and sr_severity >= ?", owner_id, severity])
    subscription = Subscription.find(:first, # TODO should handle multiple devices
    :conditions => ["user_id=? and sr_severity>=?", owner_id, severity])
    if subscription
      devices = APN::Device.find(:all, :conditions => ["token=?", subscription.token])
      if devices.empty?
        app = APN::App.first ## TODO should look up be name
        if app
          devices = [APN::Device.create(:token => subscription.token,:app => app)]
        end
      end

      logger.info "devices are  #{devices.inspect}"

      unless devices.empty?
        devices.each do |device|
          link = {:sr_number => sr_number}
          priority = "S#{severity}"
          priority += "/E#{escalation.level}" unless escalation.nil?
          notification = {:device => device, 
            :badge=>subscription.badge,
            :sound=>true, 
            :alert=>"Service Request #{sr_number} (#{priority}) was just updated",
            :custom_properties => {:sr_number => sr_number}
          }
          logger.info "notify_owner with  #{notification.inspect}"
          APN::Notification.create notification
        end
      end
    end
  end
    
end
