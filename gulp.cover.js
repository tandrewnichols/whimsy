var gulp = require('gulp');
var config = require('./config');
var mocha = require('gulp-spawn-mocha');
var cover = require('gulp-coverage');

gulp.task('cover', function() {
  return gulp.src(config.tests.unit, { read: false })
    .pipe(cover.instrument({
      pattern: 'lib/**/*.js'
    }))
    .pipe(mocha({
      reporter: 'dot',
      ui: 'mocha-given',
      require: ['coffee-script/register', 'should', 'should-sinon']
    }))
    .pipe(cover.gather())
    .pipe(cover.format([
      { reporter: 'html' },
      { reporter: 'lcov' }
    ]))
    .pipe(gulp.dest('coverage'));
});

