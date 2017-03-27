gulp = require 'gulp'
browserify = require 'browserify'
streamify = require 'gulp-streamify'
source = require 'vinyl-source-stream'
uglify = require 'gulp-uglify'
sass = require 'gulp-sass'
minifyCss = require 'gulp-minify-css'
rename = require 'gulp-rename'
_ = require 'lodash'
fs = require 'fs'
util = require 'util'

gulp.task 'default', ['coffee', 'sass']

gulp.task 'config', ->
  keys = [
    'ROOTURL'
  ]
  fs.writeFileSync 'www/js/config.json', util.inspect _.pick(process.env, keys)
  
gulp.task 'sass', (done) ->
  gulp.src './scss/index.scss'
    .pipe sass()
    .pipe gulp.dest './www/css/'
    .pipe minifyCss keepSpecialComments: 0
    .pipe rename extname: '.min.css'
    .pipe gulp.dest './www/css/'

gulp.task 'coffee', ['config'], ->
  browserify entries: ['./www/js/index.coffee']
    .transform 'coffeeify'
    .bundle()
    .pipe source 'index.js'
    .pipe gulp.dest './www/js/'
    .pipe streamify uglify()
    .pipe rename extname: '.min.js'
    .pipe gulp.dest './www/js/'
