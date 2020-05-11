if ENV['RAISE_ON_MISSING_TRANSLATIONS'] == 'TRUE'
  I18n.exception_handler = lambda do |_exception, _locale, key, options|
    full_key = [options[:scope], key].compact.join('.')
    raise "Missing translation: #{full_key}"
  end
end
