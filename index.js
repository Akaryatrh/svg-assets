#! /usr/bin/env node
;
var CliParser, SvgAssets, cliParser, options, svgAssets;

SvgAssets = require('./lib/main');

CliParser = require('./lib/cli-parser');

cliParser = new CliParser();

options = cliParser.initCommander();

if (options != null) {
  svgAssets = new SvgAssets(options);
  svgAssets.process();
}
