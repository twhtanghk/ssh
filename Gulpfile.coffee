argv = require('yargs').argv
gulp = require 'gulp'
browserify = require 'browserify'
streamify = require 'gulp-streamify'
source = require 'vinyl-source-stream'
uglify = require 'gulp-uglify'
concat = require 'gulp-concat'
sass = require 'gulp-sass'
minifyCss = require 'gulp-minify-css'
rename = require 'gulp-rename'
_ = require 'lodash'
fs = require 'fs'
util = require 'util'

config = (params) ->
  _.defaults params,
    _.pick(process.env, 'ROOTURL', 'AUTHURL', 'VERIFYURL', 'OAUTH2_SCOPE')
  fs.writeFileSync 'www/js/config.json', util.inspect(params)

gulp.task 'default', ['coffee', 'sass']

gulp.task 'sass', (done) ->
  gulp.src './scss/index.scss'
    .pipe sass()
    .pipe gulp.dest './www/css/'
    .pipe minifyCss keepSpecialComments: 0
    .pipe rename extname: '.min.css'
    .pipe gulp.dest './www/css/'

gulp.task 'coffee', ->
  browserify(entries: ['./www/js/index.coffee'])
    .transform 'coffeeify'
    .transform 'debowerify'
    .bundle()
    .pipe source 'index.js'
    .pipe gulp.dest './www/js/'
    .pipe streamify uglify()
    .pipe rename extname: '.min.js'
    .pipe gulp.dest './www/js/'
