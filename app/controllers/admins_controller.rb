# -*- coding: utf-8 -*-
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

