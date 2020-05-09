require "support/page_objects/page_base"

class SubmissionsIndexPage < PageBase
  def visit(as: nil)
    login_as(as) if as.present?

    super submissions_path
  end
end
