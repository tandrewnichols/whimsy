var gulp = require('gulp');
var open = require('gulp-open');

gulp.task('open', function() {
  return gulp.src('./coverage/coverage.html')
    .pipe(open());
});

