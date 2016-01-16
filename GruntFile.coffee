module.exports = (grunt) ->

  # ===========================================================================
  # CONFIGURE GRUNT ===========================================================
  # ===========================================================================
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    copy:
      templates:
        files: [
          expand: true,
          cwd: 'assets/'
          src: ['templates/**/*'],
          dest: 'example/'
        ]
      assets:
        files: [
          expand: true,
          cwd: 'assets/'
          src: ['files/**/*'],
          dest: 'example/'
        ]

    clean:
      example: ['example']

    coffee:
      main:
        options:
          bare: true
        expand: true
        cwd: 'src'
        src: ['*.coffee']
        dest: 'lib'
        ext: '.js'

    watch:
      coffee:
        files: [
          'src/**/*.coffee'
        ],
        tasks: ['coffee']
        options:
          liveReload: true



  # Load all plugins declared as dependencies in package.json file ------------------------------------
  pack = grunt.config.get 'pkg'
  depMatch = /^grunt-.*/
  grunt.loadNpmTasks dep for dep of pack.dependencies when depMatch.test dep

  grunt.registerTask 'prepare', [ 'clean', 'copy', 'coffee' ]
  grunt.registerTask 'example', [ 'prepare', 'run' ]

  grunt.registerTask 'run', 'Call svgAssets', ->
    SvgAssets = require './index'

    options =
      directory: 'example/templates'
      assets: 'example/files'

    svgAssets = new SvgAssets(options)
    svgAssets.process()
    return

  return