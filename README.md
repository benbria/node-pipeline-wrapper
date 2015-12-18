Combines multiple streams in a pipeline into a single stream.

Install with:

    npm install --save pipeline-wrapper

Example:

    myStream = new PipelineWrapper([x, y]);
    otherStream.pipe(myStream); // This is equivalent to otherStream.pipe(x).pipe(y)

You can use this to make your gulp files more readable:

    var coffee          = require('gulp-coffee');
    var eslint          = require('gulp-eslint');
    var PipelineWrapper = require('pipeline-wrapper');

    // This is a pipeline that encompasses many child gulp steps.  We can reuse this in multiple build tasks.
    function findUndefinedVariables() {
        return new PipelineWrapper([
            eslint({
                env: {
                    browser: true,
                    node: true
                },
                rules: {"no-undef": 2}
            ),
            eslint.format(),
            eslint.failAfterError()
        ],
        {objectMode: true});
    }

    gulp.task('build', function() {
       gulp.src("src/**/*.coffee")
       .pipe(coffee())
       .pipe(findUndefinedVariables());
    });
