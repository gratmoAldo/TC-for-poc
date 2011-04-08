class InboxSrsController < ApplicationController
  # GET /inbox_srs
  # GET /inbox_srs.xml
  def index
    @inbox_srs = InboxSr.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @inbox_srs }
    end
  end

  # GET /inbox_srs/1
  # GET /inbox_srs/1.xml
  def show
    @inbox_sr = InboxSr.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @inbox_sr }
    end
  end

  # GET /inbox_srs/new
  # GET /inbox_srs/new.xml
  def new
    @inbox_sr = InboxSr.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @inbox_sr }
    end
  end

  # GET /inbox_srs/1/edit
  def edit
    @inbox_sr = InboxSr.find(params[:id])
  end

  # POST /inbox_srs
  # POST /inbox_srs.xml
  def create
    @inbox_sr = InboxSr.new(params[:inbox_sr])

    respond_to do |format|
      if @inbox_sr.save
        flash[:notice] = 'InboxSr was successfully created.'
        format.html { redirect_to(@inbox_sr) }
        format.xml  { render :xml => @inbox_sr, :status => :created, :location => @inbox_sr }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @inbox_sr.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /inbox_srs/1
  # PUT /inbox_srs/1.xml
  def update
    @inbox_sr = InboxSr.find(params[:id])

    respond_to do |format|
      if @inbox_sr.update_attributes(params[:inbox_sr])
        flash[:notice] = 'InboxSr was successfully updated.'
        format.html { redirect_to(@inbox_sr) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @inbox_sr.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /inbox_srs/1
  # DELETE /inbox_srs/1.xml
  def destroy
    @inbox_sr = InboxSr.find(params[:id])
    @inbox_sr.destroy

    respond_to do |format|
      format.html { redirect_to(inbox_srs_url) }
      format.xml  { head :ok }
    end
  end
end
