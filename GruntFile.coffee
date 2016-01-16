module.exports = (grunt) ->

  # ===========================================================================
  # CONFIGURE GRUNT ===========================================================
  # ===========================================================================
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    prompt:
      package:
        options:
          questions: [
              config: 'pkg.newVersion'
              type: 'input'
              message: ->
                currentPackageVersion = grunt.config "pkg.version"
                return "Enter a version for this package (current: #{ currentPackageVersion }):"

              validate: (value) ->
                currentPackageVersion = grunt.config "pkg.version"
                regex = /^\d+\.\d+\.\d+(-\d+)?$/
                testValidity = (regex.test value.trim()) and (value.trim() isnt currentPackageVersion)
                testValidity

              filter: (value) ->
                value = value.trim()
          ]
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
      options:
        bare: true
      main:
        expand: true
        cwd: 'src'
        src: ['*.coffee', '!index.coffee']
        dest: 'lib'
        ext: '.js'
      indexFile:
        files:
          'index.js': 'src/index.coffee'

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
  grunt.registerTask 'example', [ 'prepare', 'run-example' ]

  grunt.registerTask 'run-example', 'Call svgAssets', ->
    SvgAssets = require './index'

    options =
      directory: 'example/templates'
      assets: 'example/files'

    svgAssets = new SvgAssets(options)
    svgAssets.process()
    return

  grunt.registerTask 'lib-index', 'Create index.js file at root of projet', ->


  grunt.registerTask 'package-version', 'Write new version for package.json file', ->
    newPackageVersion = grunt.config "pkg.newVersion"
    fileContent = grunt.file.read './package.json'
    fileContent = fileContent.replace /"version": ".+",$/m, "\"version\": \"#{ newPackageVersion }\","
    grunt.file.write './package.json', fileContent

  grunt.registerTask 'package', ['coffee', 'prompt', 'package-version']

  return