# Exec func from child_process
exec = (require 'child_process').exec

# Build Gunther
task "build", "Build Gunther", () ->
    exec "./node_modules/bin/coffee -o lib -c src", (error, stdout, stderr) ->
        if not error?
            console.log "Gunther compiled"
        else
            console.log "Build failed: #{error}"

# Minify
task "minify", "Minify Gunther's js", () ->
    exec "./node_modules/uglify-js/bin/uglifyjs -o ./lib/gunther-min.js ./lib/gunther.js"
