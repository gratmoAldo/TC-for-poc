class SessionsController < ApplicationController
  def new
    @active_admins = User.active_admin
    @active_users = User.active_normal.paginate :per_page => params[:per_page]||50, :page => params[:page], :order => 'users.username'
  end
  
  def create
    user = login params[:login], params[:password]
    if user
      flash[:notice] = "Logged in successfully."
      redirect_to_target_or_default(root_url)
    else
      flash[:error] = "Invalid login or password."
      redirect_to login_path
    end
  end
  
  def destroy
    logout
    flash[:notice] = "You have been logged out."
    redirect_to login_path
  end
end
