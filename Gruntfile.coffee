module.exports = (grunt) ->

    buildOrder = ['src/root.coffee', 'src/helper.coffee',
        'src/idGenerator.coffee', 'src/boundProperty.coffee',
        'src/boundModel.coffee', 'src/itemSubView.coffee',
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

            # Compile the tests
            compileTests:
                expand: true
                flatten: true
                cwd: 'test/coffee'
                src: ['*.coffee']
                dest: 'test/js'
                ext: '.js'

        # Uglify results
        uglify:
            options:
                banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'

            source:
                src: 'lib/<%= pkg.name %>.js'
                dest: 'lib/<%= pkg.name %>.min.js'

        # Tests
        karma:
            options:
                configFile: 'test/karma.conf.coffee'

            # Watched
            watched:
                background: true

            # Single karma run using PhantomJS
            single:
                singleRun: true
                browsers: ['PhantomJS']

        # Watch for changes in:
        watch:

            # Gunther source
            source:
                files: ['src/*.coffee', 'karma:watched:run']
                tasks: ['default']
                options:
                    nospawn: false

            # The test coffee sources
            testCoffee:
                files: ['test/coffee/**/*.coffee']
                tasks: ['coffee:compileTests', 'karma:watched:run']
                options:
                    nospawn: false

    # Load the tasks
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-karma'

    # Compile task
    grunt.registerTask 'compile', ['coffee', 'uglify']

    # Run unit tests once
    grunt.registerTask 'test', ['karma:single']

    # Development stack, watch for changes and run unit tests
    grunt.registerTask 'dev', ['karma:watched:start', 'watch']

    # Default task
    grunt.registerTask 'default', ['compile', 'test']
