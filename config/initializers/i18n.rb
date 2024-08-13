# frozen_string_literal: true

I18n.load_path += Dir["#{File.expand_path('config/locales')}/*.yml"]
I18n.available_locales = %i[en ru]
I18n.enforce_available_locales = true
I18n.fallbacks[:ru] = [:en]

module I18n
  def self.with_all_locales(&block)
    available_locales.each_with_object({}) do |locale, locales|
      locales[locale] = with_locale(locale, &block)
    end.compact_blank.with_indifferent_access
  end
end
