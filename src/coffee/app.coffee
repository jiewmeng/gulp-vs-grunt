require.config
	baseUrl: "js"
	paths:
		jquery: "../bower_components/jquery2/jquery"
		bootstrap: "../bower_components/bootstrap/dist/js/bootstrap"
	shim:
		bootstrap:
			deps: ["jquery"]

require ["jquery", "test/test", "bootstrap"], ($, test) ->

	$ ->
		console.log "it works hello world!"
		test()