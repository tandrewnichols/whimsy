var gulp = require('gulp');
var cp = require('child_process');

gulp.task('codeclimate', function(cb) {
  if (process.version.indexOf('v4') > -1) {
    cp.exec('codeclimate-test-reporter < coverage/lcov.info', function(err) {
      cb(err);
    });
  } else {
    cb();
  }
});

