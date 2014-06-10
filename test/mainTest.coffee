sharedObjectsTest = require './sharedObjectsTest'
svgAssetsTest = require './svgAssetsTest'

describe 'svgAssets instance', ->
	svgAssetsTest()

describe 'share objects', ->
	sharedObjectsTest()