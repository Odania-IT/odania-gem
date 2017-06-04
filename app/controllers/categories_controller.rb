class CategoriesController < ApplicationController
	def index
		@categories = $elasticsearch.search index: 'categories', type: 'category', body: {
			query: {
				bool: {
					must: [
						{match: {domain: @domain}},
						{match: {subdomain: @subdomain}},
						{regexp: {category: "#{@req_url}.*"}}
					]
				}
			}
		}

		 @hits = @categories['hits']['hits']
	end

	def show
		@category = params[:id]
		@pages = $elasticsearch.search index: 'contents', type: 'content', body: {
			query: {
				bool: {
					must: [
						{match: {domain: @domain}},
						{match: {subdomain: @subdomain}},
						{regexp: {category: "#{@category}.*"}}
					]
				}
			}
		}

		@hits = @pages['hits']['hits']
	end
end
