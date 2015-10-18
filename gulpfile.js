var gulp = require('gulp');
var mocha = require('gulp-spawn-mocha');
var jshint = require('gulp-jshint');
var paths = {
  unit: ['test/helpers/**/*.coffee', 'test/unit/**/*.coffee'],
  integration: ['test/helpers/**/*.coffee', 'test/integration/**/*.coffee'],
  lib: ['lib/**/*.js', 'bin/**/*.js']
};

gulp.task('unit', function() {
  return gulp.src(paths.unit, { read: false })
    .pipe(mocha({
      reporter: 'dot',
      ui: 'mocha-given',
      require: ['coffee-script/register', 'should', 'should-sinon']
    }));
});

gulp.task('int', function() {
  return gulp.src(paths.integration, { read: false })
    .pipe(mocha({
      reporter: 'dot',
      ui: 'mocha-given',
      require: ['coffee-script/register', 'should', 'should-sinon']
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
  gulp.watch(paths.lib.concat(paths.unit).concat(paths.integration), ['test']);
});

gulp.task('test', ['unit', 'int']);
gulp.task('default', ['lint', 'test']);
gulp.task('ci', ['lint', 'test']);
