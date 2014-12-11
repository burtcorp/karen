var gulp = require('gulp');
var coffee = require('gulp-coffee');
var concat = require('gulp-concat');

var paths = {
  lib: ['lib/*.coffee']
};

gulp.task('compile', function() {
  return gulp.src(paths.lib)
    .pipe(coffee())
    .pipe(concat('karen.js'))
    .pipe(gulp.dest('.'));
});
