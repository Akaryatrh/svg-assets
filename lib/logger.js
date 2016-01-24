'use strict';
var Logger, Util, clc, sharedObjects;

clc = require('cli-color');

Util = require('util');

sharedObjects = require('./shared-objects');

module.exports = Logger = (function() {
  function Logger() {
    this.cl = console.log;
    this.shared = new sharedObjects();
    this.shared.logs = this.shared.logs();
  }

  Logger.prototype.dateNow = function() {
    return new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '') + ' UTC';
  };

  Logger.prototype.log = function(shared) {
    var date, end, error, errorCl, exeCl, finalValues, info, infoCl, logOutput, missingFile, missingFiles, warnCl, warning, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
    date = this.dateNow();
    logOutput = "𝘀𝘃𝗴 𝗮𝘀𝘀𝗲𝘁𝘀 Ξ " + date;
    this.shared = shared != null ? shared : this.shared;
    if (this.shared.logs.process.filesLength > 0) {
      this.shared.logs.infos.push("" + this.shared.logs.process.tags + " <svga> tag(s) have been processed in " + this.shared.logs.process.filesLength + " file(s)");
    } else {
      this.shared.logs.warnings.push("No file processed :\n\t∷ Processing could have been aborted due to wrong options usage or unexpected error\n\t∷ No <svga> tags could have been found\n\t∷ Found <svga> tags might have not matched any files");
    }
    missingFiles = [];
    _ref = this.shared.logs.errors.missingFiles;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      missingFile = _ref[_i];
      missingFiles.push('"' + missingFile + '.svg"');
    }
    if (missingFiles.length > 0) {
      this.shared.logs.errors.globalMessages.push("" + this.shared.logs.errors.missingFiles.length + " assets file(s) not found or not readable:\n " + (missingFiles.join(',')));
    }

    /* OUTPUT */
    errorCl = clc.red;
    warnCl = clc.yellow;
    infoCl = clc.green;
    exeCl = clc.blackBright;
    if ((_ref1 = this.shared.options) != null ? _ref1.logLevels.indexOf("warning" > -1) : void 0) {
      _ref2 = this.shared.logs.warnings;
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        warning = _ref2[_j];
        logOutput += warnCl('\n→ Warning: ') + warning;
      }
    }
    if ((_ref3 = this.shared.options) != null ? _ref3.logLevels.indexOf("info" > -1) : void 0) {
      _ref4 = this.shared.logs.infos;
      for (_k = 0, _len2 = _ref4.length; _k < _len2; _k++) {
        info = _ref4[_k];
        logOutput += infoCl('\n→ Info: ') + info;
      }
    }
    if ((_ref5 = this.shared.options) != null ? _ref5.logLevels.indexOf("error" > -1) : void 0) {
      _ref6 = this.shared.logs.errors.globalMessages;
      for (_l = 0, _len3 = _ref6.length; _l < _len3; _l++) {
        error = _ref6[_l];
        logOutput += errorCl('\n→ Error: ') + error;
      }
    }
    end = (Date.now() - this.shared.logs.startDate) / 1000;
    logOutput += exeCl("\n→ svgAssets did its job in " + end + "ms");
    this.cl(logOutput);
    finalValues = {
      logOutput: logOutput,
      logs: this.shared.logs
    };
    return finalValues;
  };

  return Logger;

})();
