var gulp = require('gulp');
var mocha = require('gulp-mocha');
var paths = {
  tests: 'test/**/*.coffee',
  lib: ['lib/**/*.js', 'bin/**/*.js']
};

gulp.task('test', function() {
  return gulp.src(paths.tests, {read: false })
    .pipe(mocha({
      reporter: 'dot',
      ui: 'mocha-given',
      require: ['coffee-script/register', 'should']
    }));
});

gulp.task('watch', function() {
  gulp.watch(paths.lib.concat(paths.tests), ['test']);
});
