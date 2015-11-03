When(/^I generate the varnish config$/) do
	Odania.varnish.generate('/tmp/varnish')
end

Then(/^I have a valid varnish config$/) do
	pending # Write code here that turns the phrase above into concrete actions
end
