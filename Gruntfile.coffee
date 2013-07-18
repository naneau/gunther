module.exports = (grunt) ->

    buildOrder = ['src/root.coffee', 'src/idGenerator.coffee',
        'src/boundProperty.coffee', 'src/itemSubView.coffee',
        'src/template.coffee']

    # Project configuration.
    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        # Compile all coffee
        coffee:
            compile:
                options:
                    join: true
                files:
                    'lib/gunther.js': buildOrder

            compileWithMap:
                options:
                    join: true
                    sourceMap: true
                files:
                    'lib/gunther.mapped.js': buildOrder

        # Uglify results
        uglify:
            options:
                banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
            build:
                src: 'lib/<%= pkg.name %>.js'
                dest: 'lib/<%= pkg.name %>.min.js'

    # Load the tasks
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-uglify'

    # Default task(s).
    grunt.registerTask 'default', ['coffee', 'uglify']
