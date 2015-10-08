var gulp = require('gulp');
var mocha = require('gulp-mocha');
var jshint = require('gulp-jshint');
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

gulp.task('lint', function() {
  return gulp.src(paths.lib)
    .pipe(jshint({
      lookup: false,
      eqeqeq: true,
      es3: true,
      indent: 2,
      newcap: true,
      quotmark: 'single',
      boss: true
    })) .pipe(jshint.reporter('jshint-stylish'));
});

gulp.task('watch', function() {
  gulp.watch(paths.lib.concat(paths.tests), ['test']);
});

gulp.task('ci', ['lint', 'test']);
