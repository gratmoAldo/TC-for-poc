class ConsoleController < ApplicationController
  
  before_filter :admin_only
  # skip_before_filter :verify_authenticity_token

  def index
    @subscriptions = Subscription.all
    @last_notifications = APN::Notification.find :all, :order => 'apn_notifications.created_at DESC', :limit => 10
    @devices = APN::Device.find :all, :order => 'apn_devices.created_at DESC', :limit => 10

    respond_to do |format|
      format.html # index.html.erb
      # format.xml  { render :xml => @subscriptions }
      # format.json  { render :json => @subscriptions }
    end
  end
end
