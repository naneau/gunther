module.exports = (grunt) ->

    buildOrder = ['src/root.coffee', 'src/idGenerator.coffee',
        'src/boundProperty.coffee', 'src/itemSubView.coffee',
        'src/template.coffee']

    # Project configuration.
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        # Compile all coffee
        coffee:
            # Compile Gunther
            compile:
                options:
                    join: true
                files:
                    'lib/gunther.js': buildOrder

            # Compile Gunther, but with a source map, for debugging
            compileWithMap:
                options:
                    join: true
                    sourceMap: true
                files:
                    'lib/gunther.mapped.js': buildOrder

            # Compile the example scripts
            compileExamples:
                expand: true
                flatten: true
                options:
                    sourceMap: true
                src: ['examples/src/*.coffee']
                dest: 'examples/scripts'
                ext: '.js'

        # Uglify results
        uglify:
            options:
                banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
            build:
                src: 'lib/<%= pkg.name %>.js'
                dest: 'lib/<%= pkg.name %>.min.js'

        # Copy lib files to examples lib, for more contained distribution/testing
        copy:
            lib:
                files: [
                    expand: true, src: ['lib/*'], dest: 'examples'
                ]

        # Watch for changes
        watch:
            scripts:
                files: ['src/*.coffee']
                tasks: ['default']
                options:
                    nospawn: false

    # Load the tasks
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-copy'

    # Default task(s).
    grunt.registerTask 'default', ['coffee', 'uglify', 'copy']
