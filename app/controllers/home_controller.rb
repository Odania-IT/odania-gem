class HomeController < ApplicationController
	def redirect_to_locale
		accepted_langs = %w(de en)
		locale = http_accept_language.preferred_language_from(accepted_langs)

		redirect_to locale_root_path(locale: locale)
	end

	def index
	end
end
