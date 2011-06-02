# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Authentication, Notification

  before_filter :prepare_for_mobile
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details


  # execute block if object exists, other return 404
  def if_found(obj)
    if obj
      yield 
    else
      render :text => "Not found.", :status => "404 Not Found"
      false
    end    
  end

  private

  # General
  def development?
    ENV["RAILS_ENV"] == "development"
  end
  helper_method :development?


  # Mobile devices
  def mobile_device?
    # logger.info "$$$$$$$$$$$$$ inside mobile_device"
    # logger.info "request = #{request.inspect}"
    if session[:mobile_param]
      # logger.info "session[:mobile_param] = #{session[:mobile_param]}"
      session[:mobile_param] == "1"
    else
      # logger.info "request.user_agent = #{request.user_agent} (#{request.user_agent =~ /Mobile|webOS/})"
      request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    logger.info "params[:mobile]=#{params[:mobile]}"
    case params[:mobile]
    when '-1' # use -1 to clear the session
      session.delete(:mobile_param)
    when '0','1' # forces the view to either desktop or mobile
      session[:mobile_param] = params[:mobile]    
    end
    logger.info "session[:mobile_param]=#{session[:mobile_param]}"
    request.format = :mobile if mobile_device?
  end  

  # Text formatting
  def url_friendly(name='')
    name.downcase.gsub(/[^0-9a-z]+/, ' ').strip.gsub(' ', '-')
  end

  def highlight(txt, keywords)
    txt ||= ''
    keywords ||= []
    keywords.empty? ? txt : txt.gsub(/(#{keywords.join('|')})/i, '<label class=\'highlight\'>\1</label>')
  end

  SEP = ' ... '
  def mid_truncate(txt, truncation=40)
    sep_length = SEP.length
    return txt[0..truncation-1] if truncation < (sep_length + 2)
    return txt if txt.length <= truncation
    first_chunk = ((truncation - sep_length) / 2).to_i
    second_chunk = truncation - sep_length - first_chunk
    # puts "first_chunk = #{first_chunk}"
    # txt.gsub! /\s/,' '
    txt.gsub(/^(.{#{first_chunk}})(.*)$/,'\1')+SEP+txt.gsub(/^(.*)(.{#{second_chunk}})$/,'\2')
  end  

  def short_date(d)    
    d.nil? ? "" : d.strftime("%D %l:%M%p")
  end

  def simple_date(d)    
    d.nil? ? "" : d.strftime("%m/%d/%Y %r %Z")
  end

  def full_date(d)
    d.nil? ? "" : d.strftime("%m/%d/%Y %r %Z")
  end

  def json_date(d)
    d.nil? ? "" : d.strftime("%m/%d/%Y %H:%M:%S %Z")
  end
  helper_method :url_friendly, :highlight, :mid_truncate, :simple_date, :short_date, :full_date, :json_date


end
