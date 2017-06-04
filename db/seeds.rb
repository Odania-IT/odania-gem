# Languages
languages = %w(de en)
languages.each do |language|
	Language.find_or_create_by name: language
end
