var OptionsManager, sharedObjects;

sharedObjects = require('./shared-objects');

module.exports = OptionsManager = (function() {
  function OptionsManager() {
    this.logs = null;
    this.shared = new sharedObjects();
    this.shared.logs = this.shared.logs();
    this.shared.defaultOptions = this.shared.defaultOptions();
    this.shared.options = this.shared.defaultOptions;
  }

  OptionsManager.prototype.init = function(options) {
    var prefix, retObject, _base;
    retObject = {
      success: true,
      shared: this.shared
    };
    if (options) {
      this.shared.options = options;
    } else {
      this.shared.options = this.shared.defaultOptions();
      this.shared.logs.warnings.push("No options found -> defaults options have been used instead");
    }
    this.shared.options.logLevels = this.checkOptionsWithDefaults('logLevels');
    this.shared.options.templatesExt = this.checkOptionsWithDefaults('templatesExt', true);
    this.shared.options.assetsExt = this.checkOptionsWithDefaults('assetsExt', true);
    if ((_base = this.shared.options).preserveRoot == null) {
      _base.preserveRoot = this.shared.defaultOptions.preserveRoot;
    }
    if (!this.shared.options.directory) {
      prefix = 'No directory specified -> ';
      if (this.shared.options.preserveRoot) {
        this.shared.logs.errors.globalMessages.push("" + prefix + "processing aborted");
        retObject.success = false;
        return retObject;
      } else {
        this.shared.options.directory = '.';
        this.shared.logs.warnings.push("" + prefix + "the root of your project has been used to find <svga> tags");
      }
    }
    if (!this.shared.options.assets) {
      prefix = 'No assets folder specified -> ';
      if (this.shared.options.preserveRoot) {
        this.shared.logs.errors.globalMessages.push("" + prefix + "processing aborted");
        retObject.success = false;
        return retObject;
      } else {
        this.shared.options.assets = '.';
        this.shared.logs.warnings.push("" + prefix + "the root of your project has been used to find matching files");
      }
    }
    return retObject;
  };

  OptionsManager.prototype.checkOptionsWithDefaults = function(options, acceptAny) {
    switch (false) {
      case !(typeof this.shared.options[options] === 'string' && acceptAny):
        return [this.shared.options[options]];
      case !(typeof this.shared.options[options] === 'string' && this.checkArrayMatch([this.shared.options[options]], this.shared.defaultOptions[options])):
        return [this.shared.options[options]];
      case !(typeof this.shared.options[options] === 'string' && !this.checkArrayMatch(this.shared.options[options], this.shared.defaultOptions[options])):
        return this.returnOptionsAndWarning(options);
      case !(Array.isArray(this.shared.options[options]) && acceptAny):
        return this.shared.options[options];
      case !(Array.isArray(this.shared.options[options]) && !this.checkArrayMatch(this.shared.options[options], this.shared.defaultOptions[options])):
        return this.returnOptionsAndWarning(options);
      case !(this.shared.options[options] == null):
        return this.shared.defaultOptions[options];
      default:
        return this.shared.options[options];
    }
  };

  OptionsManager.prototype.checkArrayMatch = function(values, matches) {
    var check, value, _i, _len;
    check = false;
    for (_i = 0, _len = values.length; _i < _len; _i++) {
      value = values[_i];
      if (matches.indexOf(value) > -1) {
        check = true;
      }
    }
    return check;
  };

  OptionsManager.prototype.returnOptionsAndWarning = function(options) {
    this.shared.logs.warnings.push("Wrong " + options + " options -> default ones will be used instead");
    return this.shared.defaultOptions[options];
  };

  return OptionsManager;

})();
