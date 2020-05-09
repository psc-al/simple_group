require "support/page_objects/shared_components/navigation_component"

class PageBase
  include ActionView::Helpers::TranslationHelper
  include Capybara::DSL
  include FactoryBot::Syntax::Methods
  include Formulaic::Dsl
  include NavigationComponent
  include Rails.application.routes.url_helpers
  include Warden::Test::Helpers

  def visit(path)
    super
  end

  def has_notice?(notice)
    has_css?(".alert-notice", text: notice)
  end
end
