class UsersController < ApplicationController

  def new
  end

  def create
    cookies.delete :auth_token
    # protects against session fixation attacks, wreaks havoc with
    # request forgery protection.
    # uncomment at your own risk
    # reset_session
    @user = User.new(params[:user])
    @user.save
    if @user.errors.empty?
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

  def show
    @user = User.find(params[:id])
    @lists = List.find_all_by_user_id(params[:id])
    respond_to do |format|
      format.html # show.html.erb
    end
  end


end
