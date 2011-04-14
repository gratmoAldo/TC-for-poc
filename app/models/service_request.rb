class ServiceRequest < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :contact, :class_name => 'User', :foreign_key => 'contact_id'

  has_many :inbox_srs, :dependent => :destroy
  has_many :inboxes, 
           :through => :inbox_srs
  has_many :watchers, 
           :through => :inbox_srs,
           :source => :inbox,
           :select => "distinct inboxes.owner_id"

  belongs_to :site
  belongs_to :escalation
  after_save :notify_owner
  
  
  def queue(q)
    
  end

  def update_watcher
    logger.info("inside update_watcher")
#    users => their inboxes => inbox that don't include that sr
 
    # logger.info("inboxes for contact and owner = #{Inbox.for_owners([self.contact_id, self.owner_id]).inspect}")
    
    watchers = [self.owner_id, self.contact_id]
    a = Inbox.containing_sr_ids(self.id).only_ids.collect &:id
    b = Inbox.for_owners(watchers).collect &:id
    inbox_to_be_touched = b-a
    inbox_to_be_touched.each do |inbox_id|
      inbox = Inbox.find inbox_id
      logger.info "Adding SR ##{self.sr_number} to #{inbox.name}"
      inbox.service_requests << self
    end
#    find inboxes that do not include this service request amongst 
    
    
    
  end
  
  def notify_owner
    update_watcher
    logger.info("inside notify_owner")

# TODO should look at all users who have the SR in their inbox
    logger.info "watchers = #{self.watchers.inspect}"

    # users = self.watchers
    subscriptions = Subscription.for_watchers(self.watchers.collect(&:owner_id))
    
    logger.info "subscriptions = #{subscriptions.inspect}"
    # find(:all, # TODO should handle multiple devices
    # :conditions => ["user_id=? and sr_severity>=?", self.watchers.collect(&:owner_id), severity])
    
    subscriptions.each do |subscription|
    # subscription = subscription.first
      if subscription
        devices = APN::Device.find(:all, :conditions => ["token=?", subscription.token])
        if devices.empty?
          app = APN::App.first ## TODO should look up be name
          if app
            devices = [APN::Device.create(:token => subscription.token,:app => app)]
          end
        end

        
        sound_filename ='new_note.caf'
        
        logger.info "escalation=#{escalation_id}; sound_filename =  #{sound_filename}"
        logger.info "devices are  #{devices.inspect}"

        unless devices.empty?
          devices.each do |device|
            link = {:sr_number => sr_number}
            priority = "S#{severity}"

            if escalation_id.to_i > 0
              sound_filename = 'escalation.caf'
              priority += "/E#{escalation_id}"
            end
            notification = {:device => device, 
              :badge=>subscription.badge,
              :sound=>sound_filename, 
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
    
end
