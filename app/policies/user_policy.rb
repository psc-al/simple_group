class UserPolicy < ApplicationPolicy
  def ban?
    if record.admin?
      false
    elsif record.moderator? && user.admin?
      true
    elsif record.member? && user.has_mod_permissions?
      true
    else
      false
    end
  end
end
