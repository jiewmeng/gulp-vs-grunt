module.exports = (grunt) ->
	grunt.initConfig
		clean:
			# clean build files
			dist:
				src: ["dist"]

		copy:
			# copy assets
			assets:
				files: [{
					expand: true
					cwd: "src/assets"
					src: "**"
					dest: "dist"
				}]

			# some assets (fonts etc) needs to be moved for correct referencing, 
			# because of concatinated CSS/JS
			forProduction:
				files: [
					{
						expand: true
						cwd: "dist/bower_components/bootstrap/dist/fonts"
						src: "*"
						dest: "dist/fonts"
					},
					{
						expand: true
						cwd: "dist/bower_components/fontawesome/fonts"
						src: "*"
						dest: "dist/fonts"
					}
				]

		coffee:
			# 1:1 compile of coffee script files
			compile:
				options:
					bare: true
				files: [{
					expand: true
					cwd: "src/coffee"
					src: ["**/*.coffee"]
					dest: "dist/js"
					ext: ".js"
				}]

		requirejs:
			# concat JS files into 1 using rjs optimizer
			concat:
				options:
					baseUrl: "dist/js"
					name: "app"
					out: "dist/js/app-all.js"
					shim:
						jquery:
							exports: "jQuery"
						bootstrap:
							deps: ["jquery"]
					paths:
						jquery: "../bower_components/jquery2/jquery"
						bootstrap: "../bower_components/bootstrap/dist/js/bootstrap"

		jade:
			options:
				pretty: true
			# compile jade files
			development:
				files: [{
					expand:	true
					cwd: "src/jade"
					src: ["*.jade"]
					dest: "dist"
					ext: ".html"
				}]
			# same as jade:development except compiles with production locals
			production:
				options:
					data:
						env: "production"
				files: [{
					expand:	true
					cwd: "src/jade"
					src: ["*.jade"]
					dest: "dist"
					ext: ".html"
				}]

		less:
			# compile less files
			compile:
				files:
					"dist/css/app.css": "src/less/app.less"

		imagemin:
			# optimize images
			images:
				files: [{
					expand: true
					cwd: "src/assets/img"
					src: ["**/*.{jpg,jpeg,png,gif}"]
					dest: "src/assets/img"
				}]

		# use optimized (JS/CSS) files
		useminPrepare:
			html: "dist/*.html"
			options:
				dest: "dist"
		usemin:
			html: ["dist/*.html"]

		connect:
			development:
				options:
					livereload: true
					base: "dist"
			production:
				options:
					livereload: false
					base: "dist"
					keepalive: true


		watch:
			options:
				spawn: false
				livereload: true
			# watch and copy assets
			assets:
				files: "src/assets/**"
				tasks: ["copy:assets"]
			# watch and compile CoffeeScript
			coffee:
				files: "src/coffee/**/*.coffee"
				tasks: ["coffee"]
			# watch and compile Stylus files
			stylus:
				files: "src/less/**/*.less"
				tasks: ["less"]
			# watch and compile Jade files
			jade:
				files: "src/jade/*.jade"
				tasks: ["jade"]

	grunt.registerTask "build-production", [
		"clean"
		"copy"
		"imagemin"
		"jade:production"
		"coffee"
		"requirejs"
		"less"
		"useminPrepare"
		"concat"
		"cssmin"
		"usemin"
	]

	grunt.registerTask "build-development", [
		"clean"
		"copy:assets"
		"jade:development"
		"coffee"
		"less"
	]

	grunt.registerTask "development-watch-server", [
		"build-development"
		"connect:development"
		"watch"
	]

	grunt.registerTask "production-server", [
		"build-production"
		"connect:production"
	]


	grunt.loadNpmTasks "grunt-contrib-clean"
	grunt.loadNpmTasks "grunt-contrib-copy"
	grunt.loadNpmTasks "grunt-contrib-coffee"
	grunt.loadNpmTasks "grunt-contrib-requirejs"
	grunt.loadNpmTasks "grunt-contrib-jade"
	grunt.loadNpmTasks "grunt-contrib-less"
	grunt.loadNpmTasks "grunt-contrib-imagemin"
	grunt.loadNpmTasks "grunt-contrib-concat"
	grunt.loadNpmTasks "grunt-contrib-uglify"
	grunt.loadNpmTasks "grunt-contrib-cssmin"
	grunt.loadNpmTasks "grunt-usemin"
	grunt.loadNpmTasks "grunt-contrib-watch"
	grunt.loadNpmTasks "grunt-contrib-connect"