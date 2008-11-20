#This controller manage the home or the space for normal users
class HomeController < ApplicationController
 
  def index
    if logged_in?
      redirect_to user_path(current_user)
    end
  end
end
 
