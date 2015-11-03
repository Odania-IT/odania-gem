Feature: Varnish
	Configuration for varnish. It is the gateway from the web to the plugin infrastructure.

	Scenario: Generate config
		Given I initialize the gem
		When I registered the plugin "test-plugin"
			And I generate the varnish config
		Then I have a valid varnish config
