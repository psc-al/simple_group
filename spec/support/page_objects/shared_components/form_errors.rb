module FormErrors
  def has_missing_field_error?(field_class)
    has_css?("#{field_class}.field_with_errors", text: t('errors.messages.blank'))
  end

  def has_invalid_field_error?(field_class)
    has_css?("#{field_class}.field_with_errors", text: t('errors.messages.invalid'))
  end
end
