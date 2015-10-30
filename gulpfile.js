var gulp = require('gulp');
var sequence = require('gulp-sequence');
require('file-manifest').generate('./gulp', ['**/*.js', '!config.js']);
gulp.task('travis', sequence(['lint', 'cover', 'phantom'], 'codeclimate'));
gulp.task('test', ['cover', 'int', 'browser']);
gulp.task('default', ['lint', 'test']);
gulp.task('build', sequence('clean:dist', 'browserify', 'uglify'));
