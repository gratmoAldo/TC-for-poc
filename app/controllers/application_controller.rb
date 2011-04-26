# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authentication
  
  before_filter :prepare_for_mobile
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  helper_method :url_friendly, :highlight

  def url_friendly(name='')
    name.downcase.gsub(/[^0-9a-z]+/, ' ').strip.gsub(' ', '-')
  end
  
  def highlight(txt, keywords)
    txt ||= ''
    keywords ||= []
    keywords.empty? ? txt : txt.gsub(/(#{keywords.join('|')})/i, '<label class=\'highlight\'>\1</label>')
  end
    
  def if_found(obj)
    if obj
      yield 
    else
      render :text => "Not found.", :status => "404 Not Found"
      false
    end    
  end
  
  private

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_device?
  end  
  
end
