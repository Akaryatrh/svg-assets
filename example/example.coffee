svgAssets = require '../src/svg-assets'

options =
	directory : 'example/templates'

test = new svgAssets(options)
test.process()