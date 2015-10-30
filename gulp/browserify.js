var gulp = require('gulp');
var pkg = require('../package');
var browserify = require('browserify');

gulp.task('browserify', function() {
  browserify('./' + pkg.main, {
    standalone: 'whimsy' 
  }).bundle().pipe(gulp.dest('dist/whimsy.js'));
});
