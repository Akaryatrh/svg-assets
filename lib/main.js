var Logger, OptionsManager, SvgAssets, fs, sharedObjects;

fs = require('fs');

OptionsManager = require('./options-manager');

Logger = require('./logger');

sharedObjects = require('./shared-objects');

module.exports = SvgAssets = (function() {
  function SvgAssets(options) {
    this.options = options;
    this.cl = console.log;
    this._optionsManager = new OptionsManager;
    this._logger = new Logger;
    this.shared = new sharedObjects;
    this.shared.logs = this.shared.logs();
    return;
  }

  SvgAssets.prototype.process = function() {
    var allFiles, assetsFiles, file, initOptions, _i, _len;
    initOptions = this._optionsManager.init(this.options);
    this.shared = initOptions.shared;
    if (initOptions.success) {
      allFiles = this.walk(this.shared.options.directory, this.shared.options.templatesExt);
      assetsFiles = this.walk(this.shared.options.assets, this.shared.options.assetsExt);
      for (_i = 0, _len = allFiles.length; _i < _len; _i++) {
        file = allFiles[_i];
        this.findAndReplace(file, assetsFiles);
      }
    }
    return this._logger.log(this.shared);
  };

  SvgAssets.prototype.rfs = function(path) {
    var err, response;
    try {
      response = fs.readFileSync(path, 'UTF-8');
    } catch (_error) {
      err = _error;
      if (err.code !== 'ENOENT') {
        this.shared.logs.errors.globalMessages.push(err);
      } else {
        response = null;
      }
    }
    return response;
  };

  SvgAssets.prototype.walk = function(dir, ext) {
    var files, matcher, _walk;
    files = [];
    matcher = function(fn) {
      return fn.match(RegExp("\\.(" + (ext.join('|')) + ")"));
    };
    _walk = function(dir) {
      var fn, fns, _i, _len;
      if (!fs.statSync(dir).isDirectory()) {
        return files;
      }
      fns = fs.readdirSync(dir);
      for (_i = 0, _len = fns.length; _i < _len; _i++) {
        fn = fns[_i];
        fn = dir + '/' + fn;
        if (matcher(fn)) {
          files.push(fn);
        }
        if (fs.statSync(fn).isDirectory()) {
          _walk(fn);
        }
      }
      return files;
    };
    return _walk(dir);
  };

  SvgAssets.prototype.findAndReplace = function(path, assetsFiles) {
    var dataTemplate, pattern, res;
    dataTemplate = this.rfs(path);
    pattern = /(<svga(.*)>(.+)<\/svga>)/gi;
    res = dataTemplate.replace(pattern, (function(_this) {
      return function($0, originalString, properties, filename) {
        var asset, commentsTagPattern, newData, svgTagPattern, tags, xmlTagPattern, _i, _len;
        for (_i = 0, _len = assetsFiles.length; _i < _len; _i++) {
          asset = assetsFiles[_i];
          pattern = RegExp("/" + filename + "\\.svg$");
          if (asset.match(pattern)) {
            newData = _this.rfs(asset);
            break;
          }
        }
        if (newData == null) {
          newData = originalString;
          _this.shared.logs.errors.missingFiles.push(filename);
        } else {
          xmlTagPattern = /<(?:\?)?xml[^>]+>/i;
          newData = newData.replace(xmlTagPattern, '');
          commentsTagPattern = /<!--[^>]+>/gi;
          newData = newData.replace(commentsTagPattern, '');
          svgTagPattern = /<svg([^>]+)>/i;
          tags = 0;
          newData = newData.replace(svgTagPattern, function($0, originalProperties) {
            var newString;
            newString = "<svg" + originalProperties + properties + ">";
            tags++;
            _this.shared.logs.process.tags++;
            return newString;
          });
          if (tags > 0) {
            _this.shared.logs.process.filesLength++;
          }
          return newData;
        }
        return newData;
      };
    })(this));
    if (dataTemplate !== res) {
      fs.writeFileSync(path, res);
    }
    return res;
  };

  return SvgAssets;

})();
