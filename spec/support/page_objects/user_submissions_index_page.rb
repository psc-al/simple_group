require "support/page_objects/submissions_index_page"

class UserSubmissionsIndexPage < SubmissionsIndexPage
  def visit(user, as: nil)
    super path: user_submissions_path(user.username), as: as
  end
end
