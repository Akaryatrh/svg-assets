'use strict';
var SharedObjects;

module.exports = SharedObjects = (function() {
  function SharedObjects() {}

  SharedObjects.prototype.logs = function() {
    return {
      errors: {
        missingFiles: [],
        globalMessages: []
      },
      warnings: [],
      infos: [],
      process: {
        tags: 0,
        filesLength: 0
      },
      startDate: Date.now()
    };
  };

  SharedObjects.prototype.defaultOptions = function() {
    var option, retObject, value, _ref;
    retObject = {};
    _ref = this.optionsDefinitions;
    for (option in _ref) {
      value = _ref[option];
      if (value.defaultValue !== null) {
        retObject[option] = value.defaultValue;
      }
    }
    return retObject;
  };

  SharedObjects.prototype.optionsDefinitions = {
    directory: {
      defaultValue: '.',
      commands: '-d, --directory [path]',
      commandDescription: 'Set templates directory source (String)'
    },
    templatesExt: {
      defaultValue: ['html', 'htm', 'hbs', 'handlebars'],
      commands: '-t, --templates-ext [list]',
      commandDescription: 'Set templates authorized extensions (Array or String)'
    },
    outputDirectory: {
      defaultValue: null,
      commands: '-o, --output-directory [path]',
      commandDescription: 'Set templates directory destination (String)'
    },
    assets: {
      defaultValue: '.',
      commands: '-a, --assets [path]',
      commandDescription: 'Set assets directory source (String)'
    },
    assetsExt: {
      defaultValue: ['svg'],
      commands: '-A, --assets-ext [list]',
      commandDescription: 'Set assets authorized extensions (Array or String)'
    },
    logLevels: {
      defaultValue: ['warning', 'error', 'info'],
      commands: '-l, --log-levels [list]',
      commandDescription: 'Set level of logs (Array or String)'
    },
    preserveRoot: {
      defaultValue: true,
      commands: '-p, --preserve-root [bool]',
      commandDescription: 'Set root directories protection (Boolean)'
    }
  };

  return SharedObjects;

})();
