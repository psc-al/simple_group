module LinkHelper
  def active_link_to(name = nil, url = nil, html_options = {})
    active_class = html_options[:active] || "active"
    html_options.delete(:active)
    html_options[:class] = "#{html_options[:class]} #{active_class}".squish if current_page?(url)
    link_to(name, url, html_options)
  end
end
