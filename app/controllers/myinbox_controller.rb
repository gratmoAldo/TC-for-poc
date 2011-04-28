class MyinboxController < ApplicationController
  before_filter :login_required
  
  def index
    logger.info "inside MyinboxController/show"
    @myinbox = Inbox.owned_by(current_user).first    

    # logger.info "Gone fishing..."
    # sleep 5
    # logger.info "Back"
    
    if @myinbox.nil? then
      respond_to do |format|
        headers["Status"] = "404 Not Found"
        format.html {
          flash[:error] = "You don't appear to have an inbox (user id #{current_user})"
          redirect_to root_url
        }
        format.xml {
          render :text  => "<error>Not Found</error>", :status => "404 Not Found"
        }
        format.json {
          render :text  => "{\"error\":\"Not Found\"}", :status => "404 Not Found"
        }
      end
    else
      @service_requests = @myinbox.service_requests
      
      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @service_requests }
        format.json  {
          # render :json => {:inboxes => serialize(@inboxes)} 

          # headers["Content-Type"] = "text/javascript;"
          res = {
            :myinbox => @service_requests.map{  |sr| service_request_to_hash(sr) }, 
            :meta => {
              :server_name => request.server_name,
              :user => current_user.fullname
            }
          }                            
          render :json => res
        }
      end
    end

  end
  
  def service_request_to_hash(sr,options={})
    options.reverse_merge! :locale => @locale, :keywords => []
    {
      :sr_number => sr.sr_number,
      :title => sr.title,
      :severity => sr.severity,
      :escalation => sr.escalation_id,
      :customer => sr.site.name,
      :next_action_at => sr.next_action_at,
      :next_action_in_seconds => sr.next_action_in_seconds,
      :product => sr.product,
      :nb_notes => 1+rand(30)
    }
  end
  
end
