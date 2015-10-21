var gulp = require('gulp');
require('file-manifest').generate('./gulp', ['**/*.js', '!config.js']);
gulp.task('coverage', ['instrument', 'cover']);
gulp.task('test', ['unit', 'int']);
gulp.task('default', ['clean', 'lint', 'test']);
gulp.task('ci', ['lint', 'test', 'codeclimate']);
