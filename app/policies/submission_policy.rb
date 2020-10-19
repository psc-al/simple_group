class SubmissionPolicy < ApplicationPolicy
  relation_scope do |relation|
    if user.nil?
      relation.visible
    elsif user.admin?
      relation
    elsif user.moderator?
      relation.visible.
        or(relation.where(user_id: user.id)).
        or(relation.where(
             SubmissionRemoval.
             where(removed_by_id: user.id).
             where("#{relation.table_name}.id = submission_removals.submission_id").
             arel.exists
           ))
    else
      relation.visible.or(relation.where(user_id: user.id))
    end
  end

  def show?
    if record.removed? && removed_for_doxxing?
      user.present? && admin_or_remover?
    elsif record.removed?
      user.present? && author_admin_or_moderator?
    else
      true
    end
  end

  def edit?
    return false if user.nil?

    if record.removed?
      admin_or_remover?
    else
      author_admin_or_moderator?
    end
  end

  def update?
    return false if user.nil?

    if record.removed?
      admin_or_remover?
    else
      author_admin_or_moderator?
    end
  end

  def hard_delete?
    user.present? && ((author? && record.comments.none?) || user.admin?)
  end

  private

  def admin_or_remover?
    user.admin? || (user.moderator? && user_removed_record?)
  end

  def author_admin_or_moderator?
    author? || user.admin? || user.moderator?
  end

  def author?
    record.user_id == user.id
  end

  def user_removed_record?
    if record.is_a?(Submission)
      record.submission_removal.removed_by_id == user.id
    end
  end

  def removed_for_doxxing?
    record.submission_removal.doxxing?
  end
end
