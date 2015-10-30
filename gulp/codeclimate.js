var gulp = require('gulp');
var cp = require('child_process');
var codeclimate = require('gulp-codeclimate-reporter');

gulp.task('codeclimate', function(cb) {
  if (process.version.indexOf('v4') > -1) {
    gulp.src('coverage/lcov.info', { read: false })
      .pipe(codeclimate({
        token: 'c8d9d6be730725a6b7a02073283353c5756640ef71753a06bb96c77c7447266f'
      }));
  }
});

