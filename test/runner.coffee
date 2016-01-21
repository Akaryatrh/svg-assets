mainTest = require './mainTest'
loggerTest = require './loggerTest'
OptionsManagerTest = require './options-managerTest'
sharedObjectsTest = require './sharedObjectsTest'

describe 'shared objects instance', ->
	sharedObjectsTest.run()

describe 'options manager instance', ->
	OptionsManagerTest.run()

describe 'svgAssets instance', ->
	mainTest.run()

describe 'logger instance', ->
	loggerTest.run()
