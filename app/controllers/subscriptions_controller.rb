class SubscriptionsController < ApplicationController
  
  before_filter :login_required, :only => :update
  before_filter :admin_only, :except => :update

  skip_before_filter :verify_authenticity_token

  # PUT /subscriptions/1
  # PUT /subscriptions/1.xml
  def update
    
    # logger.info "=============================================================="
    # logger.info "#{request.inspect}"
    if current_user

      errors = nil
      
      # Sanitize the form
      form = (params[:subscription] || {}).reverse_merge!(:sr_severity => 1)

      form[:user_id] = current_user.id
      # form[:url_token] = params[:id] || ""

      display_id = (params[:id] || "")
      if display_id =~ /^[0-9a-f\-]{71}$/
        display_id = display_id.gsub('-', ' ')
        form[:notification_method] = 'apn'
      elsif display_id =~ /^[\-\_0-9a-z]{119}$/i
        form[:notification_method] = 'c2dm'
      else
        errors = "Invalid display ID #{display_id}"
      end
      form[:display_id] = display_id
      
      form[:badge] = 0 # initially, there is no notification
      
      env = params[:env]
      logger.info "env=#{env}"
      if errors.nil? && env == ENV["RAILS_ENV"]
        @subscription = Subscription.find(:first, :conditions => ["display_id = ?", form[:display_id]])
        if @subscription
          @subscription.update_attributes(form)
        else
          @subscription = Subscription.new(form)
        end
      else
        errors ||= "Invalid environment"
      end if

      # logger.info "Gone fishing..."
      # sleep 5
      # logger.info "I'm back!"

      logger.info "Subscription before save = #{@subscription.inspect} / errors = #{errors}"
    end
  
    respond_to do |format|
      if errors.nil? && @subscription && @subscription.save
        flash[:notice] = 'Subscription was successfully created.'
        format.xml  { head :ok }
        format.json  { 
          # logger.info "format = #{request.inspect}"
          render :json => {:last_subscribed_at => Time.now.strftime("%m/%d/%Y %H:%M:%S %Z")}
        }
      else
        errors ||= "unprocessable entity"
        errors ||= @subscription.errors if @subscription
        format.xml  { render :xml => errors, :status => :unprocessable_entity }
        format.json  { render :json => {:error => "unprocessable entity (#{errors})"}, :status => :unprocessable_entity }
      end
    end


  end

  # DELETE /subscriptions/1
  # DELETE /subscriptions/1.xml
  def destroy
    @subscription = Subscription.find(params[:id])
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to(console_url) }
      format.xml  { head :ok }
    end
  end
end
