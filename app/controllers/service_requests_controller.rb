class ServiceRequestsController < ApplicationController

  before_filter :login_required
  skip_before_filter :verify_authenticity_token

  # GET /service_requests
  # GET /service_requests.xml
  def index
    @service_requests = nil
    @keywords = (params[:search]||'').split(' ')

    conditions = {}
    # conditions[:sid]=params[:i].split(',') if params[:i]
    
    @service_requests = ServiceRequest.with_fulltext(@keywords).sort_by_sr_number.paginate :conditions => conditions, :page => params[:page], :per_page=>5#, :include => :tags

    logger.info "Found #{@service_requests.count} service_requests"

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @service_requests }
    end
  end

  # GET /service_requests/1
  # GET /service_requests/1.xml
  def show
    @service_request = ServiceRequest.lookup(params[:id])
    
    if @service_request.nil? then
      respond_to do |format|
        # format.html { render :text => request.user_agent }
        format.html {
          flash[:error]="Service Request #{params[:id]} not found"
          redirect_to inboxes_url
        }
        format.mobile {
          headers["Status"] = "404 Not Found"
          render :nothing => true
        }
        format.xml  { render :xml => @service_request }
      end
    else
      @watchers = User.watching_sr @service_request.id
      respond_to do |format|
        # format.html { render :text => request.user_agent }
        format.html # show.html.erb
        format.mobile #{ render :text => request.user_agent }
        format.xml  { render :xml => @service_request }
      end
    end


  end

  # GET /service_requests/new
  # GET /service_requests/new.xml
  def new
    @service_request = ServiceRequest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @service_request }
    end
  end

  # GET /service_requests/1/edit
  def edit
    @service_request = ServiceRequest.lookup(params[:id])
  end

  # POST /service_requests
  # POST /service_requests.xml
  def create
    @service_request = ServiceRequest.new(params[:service_request])

    respond_to do |format|
      if @service_request.save
        flash[:notice] = 'ServiceRequest was successfully created.'
        format.html { redirect_to(@service_request) }
        format.xml  { render :xml => @service_request, :status => :created, :location => @service_request }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /service_requests/1
  # PUT /service_requests/1.xml
  def update
    @service_request = ServiceRequest.lookup(params[:id])

    respond_to do |format|
      if @service_request.update_attributes(params[:service_request])
        flash[:notice] = 'ServiceRequest was successfully updated.'
        format.html { redirect_to(@service_request) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service_request.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /service_requests/1
  # DELETE /service_requests/1.xml
  def destroy
    @service_request = ServiceRequest.lookup(params[:id])
    @service_request.destroy

    respond_to do |format|
      format.html { redirect_to(service_requests_url) }
      format.xml  { head :ok }
    end
  end
end
