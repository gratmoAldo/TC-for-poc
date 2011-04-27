class SubscriptionsController < ApplicationController
  
  before_filter :login_required, :only => :update
  before_filter :admin_only, :except => :update
  skip_before_filter :verify_authenticity_token

  # GET /subscriptions
  # GET /subscriptions.xml
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

  # PUT /subscriptions/1
  # PUT /subscriptions/1.xml
  def update
    
    if current_user

      # Sanitize the form
      form = (params[:subscription] || {}).reverse_merge!(:sr_severity => 1, :note_added => true)

      form[:user_id] = current_user.id
      # form[:url_token] = params[:id] || ""
      form[:token] = (params[:id] || "").gsub('-', ' ')      
      form[:badge] = 0 # initially, there is no notification
      
      @subscription = Subscription.find(:first, :conditions => ["token = ?", form[:token]])      
      if @subscription
        @subscription.update_attributes(form)
      else
        @subscription = Subscription.new(form)
      end

      # logger.info "Gone fishing..."
      # sleep 5
      # logger.info "I'm back!"

      logger.info "Subscription before save = #{@subscription.inspect}"
    end
  
    respond_to do |format|
      if @subscription && @subscription.save
        flash[:notice] = 'Subscription was successfully created.'
        format.html { redirect_to subscription_path }
        format.xml  { head :ok }
        format.json  { 
          # logger.info "format = #{request.inspect}"
          render :json => {:subscription => "confirmed"}
        }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @subscription.errors, :status => :unprocessable_entity }
        format.json  { render :json => @subscription.errors, :status => :unprocessable_entity }
      end
    end


  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.xml
  def destroy
    @subscription = Subscription.find(params[:id])
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to(subscriptions_url) }
      format.xml  { head :ok }
    end
  end
end
