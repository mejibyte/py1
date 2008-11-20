class HomeController < ApplicationController
 
  def index
    if logged_in?
      redirect_to user_path(current_user)
    end
  end
end
 
