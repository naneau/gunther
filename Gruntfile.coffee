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

        # Uglify results
        uglify:
            options:
                banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'

            source:
                src: 'lib/<%= pkg.name %>.js'
                dest: 'lib/<%= pkg.name %>.min.js'

        # Watch for changes
        watch:

            # Gunther source
            source:
                files: ['src/*.coffee']
                tasks: ['default']
                options:
                    nospawn: false

    # Load the tasks
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    # Default task
    grunt.registerTask 'default', ['coffee:compileSource', 'coffee:compileSourceWithMap', 'uglify']
