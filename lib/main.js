'use strict';
var Logger, OptionsManager, SvgAssets, fs, mkdirp, sharedObjects;

fs = require('fs');

mkdirp = require('mkdirp');

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

  SvgAssets.prototype.rfds = function(path, type) {
    var err, error, response;
    try {
      switch (type) {
        case 'file':
          response = fs.readFileSync(path, 'UTF-8');
          break;
        case 'folder':
          response = fs.readdirSync(path);
      }
    } catch (_error) {
      err = _error;
      error = "Error: " + err.message;
      this.shared.logs.errors.globalMessages.push(error);
      return null;
    }
    return response;
  };

  SvgAssets.prototype.checkIfDir = function(path) {
    var err, error;
    try {
      fs.lstatSync(path);
      return fs.statSync(path).isDirectory();
    } catch (_error) {
      err = _error;
      error = "Error: " + err.message;
      this.shared.logs.errors.globalMessages.push(error);
      return null;
    }
  };

  SvgAssets.prototype.walk = function(dir, ext) {
    var files, matcher, _walk;
    files = [];
    matcher = function(fn) {
      return fn.match(RegExp("\\.(" + (ext.join('|')) + ")"));
    };
    _walk = (function(_this) {
      return function(dir) {
        var fn, fns, _i, _len;
        if (!_this.checkIfDir(dir)) {
          return files;
        }
        fns = _this.rfds(dir, 'folder');
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
    })(this);
    return _walk(dir);
  };

  SvgAssets.prototype.findAndReplace = function(path, assetsFiles) {
    var currentDir, dataTemplate, extensions, finalDir, finalPath, outputDir, pattern, res;
    dataTemplate = this.rfds(path, 'file');
    pattern = /(<svga(.*)>(.+)<\/svga>)/gi;
    res = dataTemplate.replace(pattern, (function(_this) {
      return function($0, originalString, properties, filename) {
        var asset, commentsTagPattern, newData, svgTagPattern, tags, xmlTagPattern, _i, _len;
        for (_i = 0, _len = assetsFiles.length; _i < _len; _i++) {
          asset = assetsFiles[_i];
          pattern = RegExp("/" + filename + "\\.svg$");
          if (asset.match(pattern)) {
            newData = _this.rfds(asset, 'file');
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
    outputDir = this.shared.options.outputDirectory;
    currentDir = this.shared.options.directory;
    extensions = this.shared.options.templatesExt.join('|');
    pattern = RegExp("" + currentDir + "(.*/{1})?(?:.+\\.(" + extensions + ")){1}$", "i");
    finalPath = finalDir = '';
    if (outputDir != null) {
      finalDir = path.replace(pattern, outputDir + '/$1');
      finalPath = path.replace(currentDir, outputDir + '/');
      finalPath = finalPath.replace("//", "/");
      finalDir = finalDir.replace("//", "/");
    } else {
      finalPath = path;
      finalDir = currentDir;
    }
    if (dataTemplate !== res) {
      mkdirp(finalDir, (function(_this) {
        return function(err) {
          if (err) {
            return _this.shared.logs.errors.globalMessages.push(err);
          } else {
            return fs.writeFileSync(finalPath, res);
          }
        };
      })(this));
    }
    return res;
  };

  return SvgAssets;

})();
