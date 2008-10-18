# -*- coding: utf-8 -*-
class AdminsController < ApplicationController
  def authorized?
    current_user.is_admin?
  end

  def see_me
    true
  end

  def show
    if logged_in?
    else
      flash[:error] = "Por favor identifíquese."
      redirect_to new_session_path
    end
  end
end

