svgAssetsTest = require './svgAssetsTest'
loggerTest = require './loggerTest'
sharedObjectsTest = require './sharedObjectsTest'

describe 'share objects', ->
	sharedObjectsTest.run()

describe 'svgAssets instance', ->
  	svgAssetsTest.run()

describe 'logger instance', ->
	loggerTest.run()
