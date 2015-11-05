var gulp = require('gulp');
var pkg = require('../package');
var browserify = require('browserify');
var source = require('vinyl-source-stream');
var buffer = require('vinyl-buffer');

gulp.task('browserify', function() {
  var b = browserify('./' + pkg.main, {
    standalone: 'whimsy' 
  });
  b.ignore('lapack');
  return b.bundle()
    .pipe(source('whimsy.js'))
    .pipe(buffer())
    .pipe(gulp.dest('dist'));
});
