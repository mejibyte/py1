# -*- coding: utf-8 -*-
# This controller manage the login in to Admin area
class AdminsController < ApplicationController
  
  def show
    if logged_in?
      @user = current_user
    else
      flash[:error] = "Por favor identifíquese."
      redirect_to new_session_path
    end
  end
end

