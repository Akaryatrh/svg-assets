# coffeelint: disable=no_backticks
`#! /usr/bin/env node
`
SvgAssets = require './lib/main'
CliParser = require './lib/cli-parser'
cliParser = new CliParser()
options = cliParser.initCommander()
if options?
	svgAssets = new SvgAssets options
	svgAssets.process()
