class SubmissionRemovalPolicy < ApplicationPolicy
  relation_scope do |relation|
    if user.admin?
      relation
    elsif user.moderator?
      relation.not_doxxing.or(relation.where(removed_by: user))
    else
      relation.none
    end
  end

  def show?
    if record.doxxing?
      user.admin? || record.removed_by_id == user.id
    else
      user.admin? || user.moderator?
    end
  end
end
