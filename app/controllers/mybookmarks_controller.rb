class MybookmarksController < ApplicationController
  before_filter :login_required

  def index
    @bookmarks = Bookmark.for_user(current_user.id).recently_created.paginate :per_page => params[:per_page]||15, :page => params[:page], :include => [:asset]
  end
end
