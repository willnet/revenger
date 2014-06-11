# -*- coding: utf-8 -*-
class RegistrationsController < Devise::RegistrationsController
  protected

  def after_update_path_for(user)
    edit_user_path
  end
end
