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
    var allFiles, assetsFiles, file, i, initOptions, len;
    initOptions = this._optionsManager.init(this.options);
    this.shared = initOptions.shared;
    if (initOptions.success) {
      allFiles = this.walk(this.shared.options.directory, this.shared.options.templatesExt);
      assetsFiles = this.walk(this.shared.options.assets, this.shared.options.assetsExt);
      for (i = 0, len = allFiles.length; i < len; i++) {
        file = allFiles[i];
        this.findAndReplace(file, assetsFiles);
      }
    }
    return this._logger.log(this.shared);
  };

  SvgAssets.prototype.rfds = function(path, type) {
    var err, error, error1, response;
    try {
      switch (type) {
        case 'file':
          response = fs.readFileSync(path, 'UTF-8');
          break;
        case 'folder':
          response = fs.readdirSync(path);
      }
    } catch (error1) {
      err = error1;
      error = "Error: " + err.message;
      this.shared.logs.errors.globalMessages.push(error);
      return null;
    }
    return response;
  };

  SvgAssets.prototype.checkIfDir = function(path) {
    var err, error, error1;
    try {
      fs.lstatSync(path);
      return fs.statSync(path).isDirectory();
    } catch (error1) {
      err = error1;
      error = "Error: " + err.message;
      this.shared.logs.errors.globalMessages.push(error);
      return null;
    }
  };

  SvgAssets.prototype.walk = function(dir, ext) {
    var _walk, files, matcher;
    files = [];
    matcher = function(fn) {
      return fn.match(RegExp("\\.(" + (ext.join('|')) + ")"));
    };
    _walk = (function(_this) {
      return function(dir) {
        var fn, fns, i, len;
        if (!_this.checkIfDir(dir)) {
          return files;
        }
        fns = _this.rfds(dir, 'folder');
        for (i = 0, len = fns.length; i < len; i++) {
          fn = fns[i];
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

  SvgAssets.prototype.createDirIfNotExists = function(path) {
    var err, error, error1;
    try {
      mkdirp.sync(path);
      return true;
    } catch (error1) {
      err = error1;
      error = "Error: " + err.message;
      this.shared.logs.errors.globalMessages.push(error);
      return null;
    }
  };

  SvgAssets.prototype.findAndReplace = function(path, assetsFiles) {
    var currentDir, dataTemplate, extensions, finalDir, finalPath, outputDir, pattern, res;
    dataTemplate = this.rfds(path, 'file');
    pattern = /(<svga(.*)>(.+)<\/svga>)/gi;
    res = dataTemplate.replace(pattern, (function(_this) {
      return function($0, originalString, properties, filename) {
        var asset, commentsTagPattern, i, len, newData, svgTagPattern, tags, xmlTagPattern;
        for (i = 0, len = assetsFiles.length; i < len; i++) {
          asset = assetsFiles[i];
          pattern = RegExp("(\\/)?" + filename + "\\.svg$");
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
    pattern = RegExp(currentDir + "(.*\\/{1})?(?:.+\\.(" + extensions + ")){1}$", "i");
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
      finalDir = this.createDirIfNotExists(finalDir);
      if (finalDir != null) {
        fs.writeFileSync(finalPath, res);
      }
    }
    return res;
  };

  return SvgAssets;

})();
