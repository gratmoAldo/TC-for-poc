class SubscriptionsController < ApplicationController
  
  before_filter :admin_only
  skip_before_filter :verify_authenticity_token

  # GET /subscriptions
  # GET /subscriptions.xml
  def index
    @subscriptions = Subscription.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @subscriptions }
      format.json  { render :json => @subscriptions }
    end
  end

  # GET /subscriptions/1
  # GET /subscriptions/1.xml
  def show
    @subscription = Subscription.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @subscription }
    end
  end

  # GET /subscriptions/new
  # GET /subscriptions/new.xml
  def new
    @subscription = Subscription.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @subscription }
    end
  end

  # GET /subscriptions/1/edit
  def edit
    @subscription = Subscription.find(params[:id])
  end

  # PUT /subscriptions/1
  # PUT /subscriptions/1.xml
  def update
    
    # logger.info "Updating subscription #{params[:id]}"
    # 
    # @subscription = Subscription.find(:first, :conditions => ["token = ?", params[:id]])
    # return self.create_tmp if @subscription.nil?
    # 
    # respond_to do |format|
    #   if @subscription.update_attributes(params[:subscription])
    #     flash[:notice] = 'Subscription was successfully updated.'
    #     format.html { redirect_to(@subscription) }
    #     format.xml  { head :ok }
    #   else
    #     format.html { render :action => "edit" }
    #     format.xml  { render :xml => @subscription.errors, :status => :unprocessable_entity }
    #   end
    # end
    # 

    if current_user

      # Sanitize the form
      form = (params[:subscription] || {}).reverse_merge!(
      :sr_severity => 1, 
      :note_added => true
      )

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
        format.json  { head :ok }
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
