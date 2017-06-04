class StandardFormBuilder < ActionView::Helpers::FormBuilder
	def submit(label, *args)
		options = args.extract_options!
		new_class = options[:class] || 'button'
		super(label, *(args << options.merge(:class => new_class)))
	end

	def array_text_field(method, key, val, options = {})
		@template.content_tag(
			'div',
			@template.content_tag(
				'label',
				method,
				for: "#{@object_name}_#{method}",
				class: 'input-group-addon'
			) +
				"<input type=\"text\" name=\"#{@object.class.to_s.downcase}[#{method}][#{key}]\" value=\"#{val}\" class=\"form-control\" />".html_safe,
			class: 'input-group'
		)
	end

	def array_text_area(method, key, val, options = {})
		@template.content_tag(
			'div',
			@template.content_tag(
				'label',
				method,
				for: "#{@object_name}_#{method}",
				class: 'input-group-addon'
			) +
				"<textarea name=\"#{@object.class.to_s.downcase}[#{method}][#{key}]\" class=\"form-control\">#{val}</textarea>".html_safe,
			class: 'input-group'
		)
	end

	def self.create_tagged_field(method_name)
		define_method(method_name) do |label, *args|
			options = args.extract_options!

			custom_label = options[:label] || label.to_s.humanize
			label_class = options[:label_class] || 'input-group-addon'
			options[:class] = 'form-control' if options[:class].nil?

			if @object.class.validators_on(label).collect(&:class).include? ActiveModel::Validations::PresenceValidator
				if label_class.nil?
					label_class = 'required'
				else
					label_class = label_class + ' required'
				end
			end

			@template.content_tag(
				'div',
				@template.content_tag(
					'label',
					custom_label,
					for: "#{@object_name}_#{label}",
					class: label_class
				) + super(label, *(args << options)),
				class: 'input-group'
			)
		end
	end

	field_helpers.each do |name|
		create_tagged_field(name)
	end
	create_tagged_field 'select'
end
