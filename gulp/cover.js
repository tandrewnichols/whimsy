var gulp = require('gulp');
var config = require('./config');
var mocha = require('gulp-mocha');
var istanbul = require('gulp-istanbul');

gulp.task('cover', ['clean:coverage', 'instrument'], function() {
  return gulp.src(config.tests.unit, { read: false })
    .pipe(mocha({
      reporter: 'dot',
      ui: 'mocha-given',
      require: ['coffee-script/register', 'should', 'should-sinon']
    }))
    .pipe(istanbul.writeReports());
});

