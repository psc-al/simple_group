class CommentPolicy < ApplicationPolicy
  relation_scope do |relation|
    if user.nil?
      relation.visible
    elsif user.admin?
      relation
    elsif user.moderator?
      relation.visible.
        or(relation.where(user_id: user.id)).
        or(relation.where(
             CommentRemoval.
                where(removed_by_id: user.id).
                where("#{relation.table_name}.id = comment_removals.comment_id").
                arel.exists
           ))
    else
      relation.visible.or(relation.where(user_id: user.id))
    end
  end

  def remove?
    user.present? && (user.admin? || user.moderator?)
  end

  def reply?
    user.present? && !record.removed?
  end
end
