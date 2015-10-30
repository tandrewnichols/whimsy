var gulp = require('gulp');
var uglify = require('gulp-uglify');
var rename = require('gulp-rename');
var config = require('./config');

gulp.task('uglify', function() {
  gulp.src('dist/whimsy.js')
    .pipe(uglify())
    .pipe(rename('whimsy.min.js'))
    .pipe(gulp.dest('dist'));
});
