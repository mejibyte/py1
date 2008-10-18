module AdminsHelper

  def authorized?
    current_user.is_admin?
  end

end
