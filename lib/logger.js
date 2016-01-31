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
    var date, error, finalValues, i, info, j, k, l, len, len1, len2, len3, logOutput, missingFile, missingFiles, ref, ref1, ref2, ref3, ref4, ref5, ref6, warning;
    date = this.dateNow();
    logOutput = "𝘀𝘃𝗴 𝗮𝘀𝘀𝗲𝘁𝘀 Ξ " + date;
    this.shared = shared != null ? shared : this.shared;
    if (this.shared.logs.process.filesLength > 0) {
      this.shared.logs.infos.push(this.shared.logs.process.tags + " <svga> tag(s) have been processed in " + this.shared.logs.process.filesLength + " file(s)");
    } else {
      this.shared.logs.warnings.push("No file processed :\n\t∷ Processing could have been aborted due to wrong options usage or unexpected error\n\t∷ No <svga> tags could have been found\n\t∷ Found <svga> tags might have not matched any files");
    }
    missingFiles = [];
    ref = this.shared.logs.errors.missingFiles;
    for (i = 0, len = ref.length; i < len; i++) {
      missingFile = ref[i];
      missingFiles.push('"' + missingFile + '.svg"');
    }
    if (missingFiles.length > 0) {
      this.shared.logs.errors.globalMessages.push(this.shared.logs.errors.missingFiles.length + " assets file(s) not found or not readable:\n " + (missingFiles.join(',')));
    }

    /* OUTPUT */
    if (((ref1 = this.shared.options) != null ? ref1.logLevels.indexOf("warning") : void 0) > -1) {
      ref2 = this.shared.logs.warnings;
      for (j = 0, len1 = ref2.length; j < len1; j++) {
        warning = ref2[j];
        logOutput += this.coloringOutput('warning', warning);
      }
    }
    if (((ref3 = this.shared.options) != null ? ref3.logLevels.indexOf("info") : void 0) > -1) {
      ref4 = this.shared.logs.infos;
      for (k = 0, len2 = ref4.length; k < len2; k++) {
        info = ref4[k];
        logOutput += this.coloringOutput('info', info);
      }
    }
    if (((ref5 = this.shared.options) != null ? ref5.logLevels.indexOf("error") : void 0) > -1) {
      ref6 = this.shared.logs.errors.globalMessages;
      for (l = 0, len3 = ref6.length; l < len3; l++) {
        error = ref6[l];
        logOutput += this.coloringOutput('error', error);
      }
    }
    logOutput += this.coloringOutput('exec');
    this.cl(logOutput);
    finalValues = {
      logOutput: logOutput,
      logs: this.shared.logs
    };
    return finalValues;
  };

  Logger.prototype.coloringOutput = function(type, message) {
    var end, errorCl, exeCl, finalMessage, infoCl, method, warnCl, wording;
    errorCl = clc.red;
    warnCl = clc.yellow;
    infoCl = clc.green;
    exeCl = clc.blackBright;
    if (message == null) {
      message = '';
    }
    wording = '';
    switch (type) {
      case "warning":
        method = warnCl;
        wording = 'Warning: ';
        break;
      case 'error':
        method = errorCl;
        wording = 'Error: ';
        break;
      case 'info':
        method = infoCl;
        wording = 'Info: ';
        break;
      case 'exec':
        method = exeCl;
        end = (Date.now() - this.shared.logs.startDate) / 1000;
        wording = "svgAssets did its job in " + end + "ms";
    }
    finalMessage = "\n→ " + wording;
    return method(finalMessage) + message;
  };

  return Logger;

})();
