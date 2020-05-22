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
    has_flash?(:notice, notice)
  end

  def has_alert?(alert)
    has_flash?(:alert, alert)
  end

  private

  def has_flash?(kind, msg)
    has_css?(".flash-#{kind}", text: msg)
  end
end
