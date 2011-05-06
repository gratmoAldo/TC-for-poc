# This module is included in your application controller which makes
# several methods available to all controllers and views. Here's a
# common example you might add to your application layout file.
# 
#   <% if logged_in? %>
#     Welcome <%=h current_user.username %>! Not you?
#     <%= link_to "Log out", logout_path %>
#   <% else %>
#     <%= link_to "Sign up", signup_path %> or
#     <%= link_to "log in", login_path %>.
#   <% end %>
# 
# You can also restrict unregistered users from accessing a controller using
# a before filter. For example.
# 
#   before_filter :login_required, :except => [:index, :show]
module Authentication
  def self.included(controller)
    controller.send :helper_method, :login, :current_user, :logged_in?, :redirect_to_target_or_default, :admin?
    controller.filter_parameter_logging :password
  end

  def set_session_for_user(user)
    # logger.info "inside set_session_for_user with user=#{user.inspect}"
    if user
      session[:locale] = user.locale
      session[:access_level] = user.access_level
      session[:user_id] = user.id
    else
      session[:locale] = nil
      session[:access_level] = nil
      session[:user_id] = nil
    end
    user
  end


  def authenticate_from_request!
    # logger.info "inside authenticate_from_request! with request=#{request.inspect}"
    case request.format
    when Mime::XML, Mime::JSON
      # logger.info "format is xml or json"
      # logger.info "current user is #{current_user.inspect}"
      # if current_user.nil?
        username, passwd = authenticate_with_http_basic { |u, p| 
          # logger.info "u=#{u} / p=#{p}"
          # User.authenticate(u,p)
          [u,p]
        }
        
        # Validate and set new user if you find new credentials
        # invalid credentials will clear the current user
        set_session_for_user User.authenticate(username,passwd) unless username.nil?
        
      # end
    else      
      # logger.info "format is something else"
      set_session_for_user User.authenticate(params[:login], params[:password]) if params[:login]
    end
  end

  def current_user
    @locale ||= params[:l]||session[:locale]||"en_US"
    @access_level ||= params[:a]||session[:access_level]||10
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end
  
  def login(id, password)
    set_session_for_user User.authenticate(id, password)    
  end
  
  def logout
    set_session_for_user nil
  end
  
  def admin?
    # return false if current_user.nil?
    (current_user && current_user.is_admin)||false  # nil? to avoid empty result. expecting true or false
  end
  
  def admin_only
    # logger.info "inside admin_only"
    authenticate_from_request!
    unless admin?
      respond_to do |format|
        format.html {
          flash[:error] = "Sorry, you are not authorized for this action."
          redirect_to assets_url
        }
        format.xml {
          render :text  => "<error>Unauthorized Access</error>", :status => "401 Unauthorized"
        }
        format.json {
          render :text  => "{\"error\":\"Unauthorized Access\"}", :status => "401 Unauthorized"
        }
      end

    end
  end
  
  def logged_in?
    current_user
  end
  
  def login_required
    authenticate_from_request!
    unless logged_in?
      # logger.info "login_required() - YOU ARE NOT LOGGED IN!"
      respond_to do |format|
        format.html {
          flash[:error] = "You must first log in or sign up before accessing this page."
          store_target_location
          redirect_to login_url
        }
        format.mobile {
          render :text => "", :status => "401 Unauthorized"
        }
        format.xml {
          render :text  => "<error>Unauthorized Access</error>", :status => "401 Unauthorized"
        }
        format.json {
          render :text  => "{\"error\":\"Unauthorized Access\"}", :status => "401 Unauthorized"
        }
      end
    end
  end
  
  def login_optional
    current_user
    true
  end
  
  def redirect_to_target_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end
  
  private
  
  def store_target_location
    session[:return_to] = request.request_uri
  end
end
