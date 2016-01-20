'use strict'

fs = require 'fs'
sharedObjects = require './shared-objects'
commander = require 'commander'

module.exports = class CliParser

  constructor: ->
    @shared = new sharedObjects()

  initCommander: () ->
    commander
      .version(@getVersion())
      .option('-r, --run', 'Run svg-assets with defaults options if no supplemental argument')
    # Construct commander options based on options definitions
    for option, value of @shared.optionsDefinitions
      commander.option value.commands, value.commandDescription
    commander.parse(process.argv)
    # Output help if no options
    if process.argv.slice(2).length is 0 or !commander.run
      commander.outputHelp()
    # Launch if run command found
    else if commander.run
      @matchArguments()
      

  getVersion: () ->
    packageFile = fs.readFileSync './package.json', 'UTF-8'
    JSON.parse(packageFile).version

  matchArguments: () ->
    options = {}
    for option of @shared.optionsDefinitions
      options[option] = commander[option] if commander[option]?
    options

