class NotesController < ApplicationController

  before_filter :login_required, :only => [:create]
  before_filter :admin_only, :except => [:update, :create]

  skip_before_filter :verify_authenticity_token
  # GET /notes
  # GET /notes.xml
  def index
    @notes = nil
    @keywords = (params[:search]||'').split(' ')

    @notes = Note.with_fulltext(@keywords).paginate :page => params[:page], :per_page => 5, :order => 'updated_at desc'

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @notes }
    end
  end

  # GET /notes/new
  # GET /notes/new.xml
  def new
    @new_note = Note.new :created_by => current_user.id, :effort_minutes => 1, :note_type => "Research",
    :service_request_id => ServiceRequest.last.id
    
    logger.info "new_note=#{@new_note.inspect}" 

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @note }
    end
  end

  # GET /notes/1/edit
  def edit
    @note = Note.find(params[:id])
  end

  # POST /notes
  # POST /notes.xml
  def create
    @note = Note.new(params[:note])
    @note.created_by = current_user.id
    
    respond_to do |format|
      if @note.save

        # TODO need to remove myself from list of watchers
        send_notifications :event => :sr_note_added, :data => {:note => @note},
          :user_ids => @note.service_request.watchers.collect(&:owner_id)
        
        flash[:notice] = 'Note was successfully created.'
        format.html { redirect_to(@note.service_request) }
        format.xml  { render :xml => @note, :status => :created, :location => @note }        
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /notes/1
  # PUT /notes/1.xml
  def update
    @note = Note.find(params[:id])

    respond_to do |format|
      if @note.update_attributes(params[:note])
        flash[:notice] = 'Note was successfully updated.'
        format.html { redirect_to(@note) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @note.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /notes/1
  # DELETE /notes/1.xml
  def destroy
    @note = Note.find(params[:id])
    @note.destroy

    respond_to do |format|
      format.html { redirect_to(notes_url) }
      format.xml  { head :ok }
    end
  end
end
