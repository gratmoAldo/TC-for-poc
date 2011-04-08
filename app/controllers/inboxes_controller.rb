class InboxesController < ApplicationController

  # before_filter :admin_only
  
  # GET /inboxes
  # GET /inboxes.xml
  def index
    @inboxes = Inbox.all
    
    # logger.info "Gone finshing..."
    # sleep 3
    # logger.info "I'm back!"
    
    # logger.info "Arming the notification"
    # device = APN::Device.first
    # notification = APN::Notification.create(:device=>device, :badge=>5, :sound=>true, :alert=>"Do you copy? Sent #{DateTime.now}", :custom_properties=>{:sr_number=>34567})

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inboxes }
      format.json  {
        # render :json => {:inboxes => serialize(@inboxes)} 

        # headers["Content-Type"] = "text/javascript;"
        res = {
          :inboxes => @inboxes.map{  |inbox| inbox_to_hash(inbox) }, 
          :meta => {
            :page => @page,
            :per_page => @per_page
          }
        }                            
        render :json => res
      }
    end
  end

  # GET /inboxes/1
  # GET /inboxes/1.xml
  def show
    @inbox = Inbox.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @inbox }
      format.json  { 
        render :json => { :meta => inbox_to_hash(@inbox),
           :service_requests => @inbox.service_requests.map{  |sr| service_request_to_hash(sr) }
           }
      }
    end
  end

  # GET /inboxes/new
  # GET /inboxes/new.xml
  def new
    @inbox = Inbox.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @inbox }
    end
  end

  # GET /inboxes/1/edit
  def edit
    @inbox = Inbox.find(params[:id])
  end

  # POST /inboxes
  # POST /inboxes.xml
  def create
    @inbox = Inbox.new(params[:inbox])

    respond_to do |format|
      if @inbox.save
        flash[:notice] = 'Inbox was successfully created.'
        format.html { redirect_to(@inbox) }
        format.xml  { render :xml => @inbox, :status => :created, :location => @inbox }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @inbox.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inboxes/1
  # PUT /inboxes/1.xml
  def update
    @inbox = Inbox.find(params[:id])

    respond_to do |format|
      if @inbox.update_attributes(params[:inbox])
        flash[:notice] = 'Inbox was successfully updated.'
        format.html { redirect_to(@inbox) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @inbox.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inboxes/1
  # DELETE /inboxes/1.xml
  def destroy
    @inbox = Inbox.find(params[:id])
    @inbox.destroy

    respond_to do |format|
      format.html { redirect_to(inboxes_url) }
      format.xml  { head :ok }
    end
  end
  

  private

  def inbox_to_hash(inbox,options={})
    options.reverse_merge! :locale => @locale, :keywords => []
    # { :access_level => asset.access_level, 
    #   :locale => options[:locale],
    #   :da_type => asset.da_type,
    #   :da_subtype => asset.da_subtype,
    #   :published_at => asset.published_at.to_i,
    #   :expire_at => asset.expire_at.to_i,        
    #   :xid => asset.xid,
    #   :title => asset.title(options[:locale]),
    #   :abstract => asset.abstract(options[:locale]),
    #   :hxid => highlight(asset.xid,options[:keywords]),
    #   :htitle => highlight(asset.title(options[:locale]),options[:keywords]),
    #   :habstract => highlight(asset.abstract(options[:locale]),options[:keywords]),
    #   :short_title => asset.short_title(options[:locale]),
    #   :link => asset_url("#{asset.sid}_#{url_friendly(asset.title(@locale))}")
    #    }
    {
      :name => inbox.name,
      :owner_name => inbox.owner.fullname,
      :owner_id => inbox.owner.id,
      :link => inbox_url(inbox)      
    }
  end

  def service_request_to_hash(sr,options={})
    options.reverse_merge! :locale => @locale, :keywords => []
    # { :access_level => asset.access_level, 
    #   :locale => options[:locale],
    #   :da_type => asset.da_type,
    #   :da_subtype => asset.da_subtype,
    #   :published_at => asset.published_at.to_i,
    #   :expire_at => asset.expire_at.to_i,        
    #   :xid => asset.xid,
    #   :title => asset.title(options[:locale]),
    #   :abstract => asset.abstract(options[:locale]),
    #   :hxid => highlight(asset.xid,options[:keywords]),
    #   :htitle => highlight(asset.title(options[:locale]),options[:keywords]),
    #   :habstract => highlight(asset.abstract(options[:locale]),options[:keywords]),
    #   :short_title => asset.short_title(options[:locale]),
    #   :link => asset_url("#{asset.sid}_#{url_friendly(asset.title(@locale))}")
    #    }
    {
      :title => sr.title
    }
  end

end
