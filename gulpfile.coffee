gulp = require "gulp"
coffee = require "gulp-coffee"
rjs = require "gulp-requirejs"
rimraf = require "rimraf"
jade = require "gulp-jade"
less = require "gulp-less"
watch = require "gulp-watch"
livereload = require "gulp-livereload"
runSequence = require "run-sequence"
connect = require "gulp-connect"
imagemin = require "gulp-imagemin"
concat = require "gulp-concat"
minifyCss = require "gulp-minify-css"
uglify = require "gulp-uglify"
usemin = require "gulp-usemin"
rjsReplace = require "gulp-requirejs-replace-script"

# delete dist directory
gulp.task "clean", (done) ->
	rimraf "dist", done

# copy assets folder
gulp.task "copy-assets", ->
	gulp.src "src/assets/**/*"
		.pipe gulp.dest "dist"

# 1:1 compile of coffee script files
gulp.task "coffee", ->
	gulp.src "src/coffee/**/*.coffee"
		.pipe coffee({bare: true})
		.pipe gulp.dest("dist/js")

# concat JS using RequireJS optimizer
gulp.task "optimized-js", ["copy-assets", "coffee"], ->
	rjs({
		baseUrl: "dist/js"
		name: "app"
		out: "app-all.js"
		paths:
			jquery: "../bower_components/jquery2/jquery"
			bootstrap: "../bower_components/bootstrap/dist/js/bootstrap"
	}).pipe uglify()
	.pipe gulp.dest("dist/js")

# compile jade files
gulp.task "jade", ->
	gulp.src "src/jade/*.jade"
		.pipe jade()
		.pipe gulp.dest("dist")

# same as jade except compiles with production locals
gulp.task "production-jade", ->
	gulp.src "src/jade/*.jade"
		.pipe jade
			locals: 
				env: "production"
		.pipe gulp.dest("dist")

# compile less files
gulp.task "less", ->
	gulp.src "src/less/app.less"
		.pipe less()
		.pipe gulp.dest("dist/css")

# concat css
gulp.task "concat", ["copy-assets", "less"], ->
	gulp.src([
		"dist/bower_components/bootstrap/dist/css/bootstrap.css"
		"dist/bower_components/bootstrap/dist/css/bootstrap-theme.css"
		"dist/css/app.css"
	]).pipe concat("app-all.css")
	.pipe gulp.dest("dist/css")

# optimize images
gulp.task "imagemin", ->
	gulp.src "src/assets/img/**/*"
		.pipe imagemin()
		.pipe gulp.dest("dist/img")

# use optimized (JS/CSS) files
gulp.task "usemin", ["production-jade"], ->
	gulp.src "dist/*.html"
		.pipe(usemin {
			css: ["concat", minifyCss()]
		}).pipe gulp.dest("dist")

# development build (separate files, unoptimized images)
gulp.task "build-dev", ->
	runSequence "clean", ["copy-assets", "coffee", "jade", "less"]

# production build (concatinated, minified files, optimized images)
gulp.task "build-production", ->
	runSequence "clean", ["copy-assets", "coffee", "optimized-js", "jade", "less", "imagemin", "usemin", "copy-assets-for-production"]

# some assets (fonts etc) needs to be moved for correct referencing, 
# because of concatinated CSS/JS
gulp.task "copy-assets-for-production", ["copy-assets"], ->
	gulp.src [
		"dist/bower_components/bootstrap/dist/fonts/*"
		"dist/bower_components/fontawesome/fonts/*"
	]
	.pipe gulp.dest("dist/fonts")

# watch, livereload, connect server
gulp.task "development-watch-server", ->
	connect.server
		root: "dist"
		livereload: true

	watch {name: "assets", glob: "src/assets/**/*"}
		.pipe gulp.dest("dist")

	watch {name: "images", glob: "src/assets/img"}
		.pipe imagemin()
		.pipe gulp.dest("dist/img")
	
	watch {name: "coffee", glob: "src/coffee/**/*.coffee"}
		.pipe coffee({bare: true})
		.pipe gulp.dest("dist/js")

	watch {name: "less", glob: "src/less/**/*.less"}
		.pipe less()
		.pipe gulp.dest("dist/css")

	watch {name: "jade", glob: "src/jade/*.jade"}
		.pipe jade()
		.pipe gulp.dest("dist")

	watch {name: "dist", glob: "dist/**"}
		.pipe connect.reload()

# Start a production server (meant for testing production files). 
# Whether minified files work
gulp.task "production-server", ["build-production"], ->
	connect.server
		root: "dist"
		livereload: false

# alias to "development-watch-server"
gulp.task "default", ->
	gulp.start "development-watch-server"