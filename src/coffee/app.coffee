require.config
	baseUrl: "."
	paths:
		jquery: "bower_components/jquery2/jquery"
		bootstrap: "bower_components/bootstrap/dist/js/bootstrap"

require ["jquery", "bootstrap"], ($) ->
	
	$ ->
		console.log "it works"