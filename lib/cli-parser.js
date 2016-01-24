'use strict';
var CliParser, commander, fs, sharedObjects;

fs = require('fs');

sharedObjects = require('./shared-objects');

commander = require('commander');

module.exports = CliParser = (function() {
  function CliParser() {
    this.shared = new sharedObjects();
  }

  CliParser.prototype.initCommander = function(args) {
    var option, value, _ref;
    args = args || process.argv;
    commander.version(this.getVersion()).option('-r, --run', 'Run svg-assets with defaults options if no supplemental argument');
    _ref = this.shared.optionsDefinitions;
    for (option in _ref) {
      value = _ref[option];
      commander.option(value.commands, value.commandDescription);
    }
    commander.parse(args);
    if (args.slice(2).length === 0 || !commander.run) {
      return commander.outputHelp();
    } else if (commander.run) {
      return this.matchArguments();
    }
  };

  CliParser.prototype.getVersion = function() {
    var packageFile;
    packageFile = fs.readFileSync('./package.json', 'UTF-8');
    return JSON.parse(packageFile).version;
  };

  CliParser.prototype.matchArguments = function(testOptions) {
    var option, options;
    options = {};
    commander = testOptions || commander;
    for (option in this.shared.optionsDefinitions) {
      if (option === 'preserveRoot' && typeof commander[option] !== 'boolean') {
        if (commander[option] === 'false') {
          commander[option] = false;
          options.directory = this.shared.optionsDefinitions.directory.defaultValue;
          options.assets = this.shared.optionsDefinitions.assets.defaultValue;
        } else {

        }
      }
      if (commander[option] != null) {
        options[option] = commander[option];
      }
    }
    return options;
  };

  return CliParser;

})();
