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
    return {
      templatesExt: ['html', 'htm', 'hbs', 'handlebars'],
      assetsExt: ['svg'],
      logLevels: ['warning', 'error', 'info'],
      preserveRoot: true
    };
  };

  return SharedObjects;

})();
