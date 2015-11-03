Feature: Plugins
	I can register and query all available plugins for the odania portal.

	Scenario: Registering a new plugin
		Given I initialize the gem
		When I registered the plugin "test-plugin"
		Then I should see "1" instances of the plugin "test-plugin"

	Scenario: Registering multiple instances of one plugin
		Given I initialize the gem
		When I registered the plugin "test-plugin"
			And I registered the plugin "test-plugin"
			And I registered the plugin "test-plugin"
		Then I should see "3" instances of the plugin "test-plugin"

	Scenario: Registering multiple plugins
		Given I initialize the gem
		When I registered the plugin "test-plugin"
			And I registered the plugin "test-plugin"
			And I registered the plugin "test-plugin-2"
		Then I should see "2" instances of the plugin "test-plugin"
			And I should see "1" instances of the plugin "test-plugin-2"

	Scenario: Retrieving plugin instance name
		Given I initialize the gem
		When I retrieve plugin instance name for "test-plugin"
			And I retrieve plugin instance name for "test-plugin"
		Then I should retrieve "test-plugin_1"

	Scenario: Build new joined plugin config
		Given I initialize the gem
		When I registered the plugin "test-plugin"
			And I generate the joined plugin config
		Then I have a joined plugin config
			And The joined plugin config contains the plugin "test-plugin"
