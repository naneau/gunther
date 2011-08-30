# Exec func from child_process
exec = (require 'child_process').exec
saiga = require 'saiga'

# Files to build, in order
buildOrder = ['root.coffee', 'html.coffee', 'boundProperty.coffee', 'itemSubView.coffee', 'template.coffee']

# Build Gunther
task "build", "Build Gunther", () ->
    exec "./node_modules/coffee-script/bin/coffee -o lib -j gunther -c ./src/#{buildOrder.join ' ./src/'}", (error, stdout, stderr) ->
        if not error?
            console.log 'Gunther compiled'
            invoke 'minify'
        else
            console.log "Build failed: #{error}"

# Minify
task "minify", "Minify Gunther's js", () ->
    exec "./node_modules/uglify-js/bin/uglifyjs -o ./lib/gunther-min.js ./lib/gunther.js", (error, stdout, stderr) ->
        if not error?
            console.log 'Gunther minified'
        else
            console.log "Could not minify: #{error}"

# Watch for changes
task "watch", "Watch for changes and recompile", () ->
    saiga.watch.directory './src', (changedFile) ->
        console.log "A file changed, re-building"
        invoke "build"
