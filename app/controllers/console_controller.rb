class ConsoleController < ApplicationController
  
  before_filter :admin_only
  # skip_before_filter :verify_authenticity_token

  def index
    @subscriptions = Subscription.find :all, :order => 'subscriptions.updated_at DESC', :limit => 20
    @last_apn_notifications = APN::Notification.find :all, :order => 'apn_notifications.created_at DESC', :limit => 10
    @last_apn_devices = APN::Device.find :all, :order => 'apn_devices.last_registered_at DESC', :limit => 10
    
    @last_android_notifications = C2dm::Notification.find :all, :order => 'c2dm_notifications.created_at DESC', :limit => 10
    @last_android_devices = C2dm::Device.find :all, :order => 'c2dm_devices.last_registered_at DESC', :limit => 10

    respond_to do |format|
      format.html # index.html.erb
      # format.xml  { render :xml => @subscriptions }
      # format.json  { render :json => @subscriptions }
    end
  end
end
