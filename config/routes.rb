Rails.application.routes.draw do
	namespace :admin do
		resources :languages
	end

	scope '/:locale', constraints: {locale: /[a-z][a-z]/} do
		get 'categories' => 'categories#index'
		get 'categories/:id' => 'categories#show'

		root to: 'home#index', as: :locale_root
	end

	root to: 'home#redirect_to_locale'
end
