$instances = Hash.new(0)

Given(/^I initialize the gem$/) do
	$instances = Hash.new(0)
	`rm -f #{Odania::Plugin::INSTANCE_FILES_PATH}*`

	Odania.plugin.get_all.each_pair do |name, instances|
		instances.each do |instance|
			if instance.ServiceName.start_with? 'test-plugin'
				puts "Deregister: #{instance}" if $debug
				Odania.plugin.deregister instance.ServiceID
			end
		end
	end
end

Given(/^I registered the plugin "([^"]*)"$/) do |plugin_name|
	plugin_cfg = {
		'name' => plugin_name,
		'ip' => '127.0.0.1',
		'port' => 80,
		'tags' => ["plugin-#{plugin_name}"],
		'default_subdomains' => {
			'_general' => 'default_sub'
		},
		'domains' => {
			'odania.com' => {
				'contents' => {
				},
				'assets' => {
				},
				'config' => {
					'asset_url' => 'assets.odania.com',
					'languages' => %w(de en),
					'layout' => 'simple',
					'language_selector' => 'prefix',
					'default_subdomain' => 'page_sub',
					'redirects' => {
						'^/test' => '/games'
					}
				},
				'public_pages' => {
				}
			}
		},
		'layouts' => {
		}
	}

	$instances[plugin_name] += 1
	plugin_instance_name = "#{plugin_name}_#{$instances[plugin_name]}"
	Odania.plugin.register plugin_instance_name, plugin_cfg
end

Then(/^I should see "([^"]*)" instances of the plugin "([^"]*)"$/) do |amount, plugin_name|
	plugins = Odania.plugin.get_all
	expect(plugins[plugin_name].count).to eq(amount.to_i)
end

When(/^I retrieve plugin instance name for "([^"]*)"$/) do |plugin_name|
	@plugin_instance_name = Odania.plugin.get_plugin_instance_name plugin_name
end

Then(/^I should retrieve "([^"]*)"$/) do |plugin_instance_name|
	expect(plugin_instance_name).to eq(@plugin_instance_name)
end

When(/^I generate the joined plugin config$/) do
	Odania.plugin.plugin_config.load_from_consul
	Odania.plugin.plugin_config.generate
end

Then(/^I have a joined plugin config$/) do
	pending # Write code here that turns the phrase above into concrete actions
end

Then(/^The joined plugin config contains the plugin "([^"]*)"$/) do |arg1|
	pending # Write code here that turns the phrase above into concrete actions
end
