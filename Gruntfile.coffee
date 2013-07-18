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
            compileSource:
                options:
                    join: true
                files:
                    'lib/gunther.js': buildOrder

            # Compile Gunther, but with a source map, for debugging
            compileSourceWithMap:
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

        # Examples less
        less:
            development:
                options:
                    paths: ["examples/styles"]
                files:
                    "./examples/styles/examples.css": "./examples/styles/examples.less"

        # Uglify results
        uglify:
            options:
                banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'

            source:
                src: 'lib/<%= pkg.name %>.js'
                dest: 'lib/<%= pkg.name %>.min.js'

        # Copy lib files to examples lib, for more contained distribution/testing
        copy:
            libToExamples:
                files: [
                    expand: true, src: ['lib/gunther.mapped.*'], dest: 'examples'
                ]

        # Watch for changes
        watch:

            # Gunther source
            source:
                files: ['src/*.coffee']
                tasks: ['default']
                options:
                    nospawn: false

            # Examples coffee source
            examplesCoffee:
                files: ['examples/src/*.coffee']
                tasks: ['coffee:compileExamples']
                options:
                    nospawn: false

            # Examples less styling
            examplesLess:
                files: ['examples/styles/*.less']
                tasks: ['less']
                options:
                    nospawn: false

    # Load the tasks
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-less'

    # Default task
    grunt.registerTask 'default', ['coffee:compileSource', 'coffee:compileSourceWithMap', 'copy:libToExamples', 'uglify']

    # Full examples compile
    grunt.registerTask 'examples', ['coffee:compileExamples', 'copy:libToExamples', 'less']
