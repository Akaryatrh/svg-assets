SvgAssets = require '../src/svg-assets'
OptionsManager = require '../src/options-manager'
Logger = require '../src/logger'
chai = require 'chai'
sinon = require 'sinon'
fs = require 'fs'

expect = chai.expect
chai.should()


module.exports = ->


	svgAssets = new SvgAssets

	describe '@constructor', ->

		it 'should have a shorthand method to console.log', ->
			mock = console.log

			expect(svgAssets.cl).to.be.a 'function'
			expect(svgAssets.cl).to.equal mock


		it 'should have created an instance of the OptionsManager', ->
			expect(svgAssets._optionsManager).to.be.an 'object'
			expect(svgAssets._optionsManager).to.be.an.instanceof OptionsManager


		it 'should have created an instance of the Logger', ->
			expect(svgAssets._logger).to.be.an 'object'
			expect(svgAssets._logger).to.be.an.instanceof Logger




	describe '@rfs', ->


		it 'should try to read synchronously an accessible svg file and should return its content', ->
			mock ="""
<svg height="400" width="450">
	<path id="lineAB" d="M 100 350 l 150 -300" stroke="red" stroke-width="3" fill="none" />
</svg>
			"""
			path = './test/assets/file.svg'

			expect(svgAssets.rfs).to.be.a 'function'
			expect(svgAssets.rfs(path)).to.equal mock


		it 'should fail to read synchronously a missing svg file and should return null', ->
			path = './test/assets/fake.svg'
			expect(svgAssets.rfs(path)).to.equal null




	describe '@walk', ->

		it 'should walk through multiples directories and return all svg files found', ->
			path = './test/assets'
			files = [
				"./test/assets/file.svg"
				"./test/assets/sub/file1.svg"
				"./test/assets/sub2/file2.svg"
				"./test/assets/sub2/file3.svg"
				"./test/assets/sub2/sub2_1/file4.svg"
			]
			extensions = ['svg']

			expect(svgAssets.walk).to.be.a 'function'
			expect(svgAssets.walk(path, extensions)).to.include.members files

		it 'should return an empty array if the target directory is empty', ->
			path = './test/assets/emptySub'
			files = []
			extensions = ['svg']

			expect(svgAssets.walk(path, extensions)).to.include.members files





	describe '@findAndReplace', ->

		beforeEach ->
			#We stub the writeFileSync method
			sinon.stub fs, "writeFileSync"

		afterEach ->
			fs.writeFileSync.restore()


		it 'should replace a <svga> tag with an existing matching file', ->
			assetsFiles = ["./test/assets/file.svg"]
			path = './test/templates/template.html'
			mock = """
<!doctype html>
<html>
	<head>
	</head>
	<body>
		<svg height="400" width="450">
	<path id="lineAB" d="M 100 350 l 150 -300" stroke="red" stroke-width="3" fill="none" />
</svg>
	</body>
</html>
			"""
			call = svgAssets.findAndReplace path, assetsFiles

			expect(call).to.equal mock


		it 'should leave untouched the template file if not matching svg file found', ->
			assetsFiles = ["./test/assets/fake.svg"]
			path = './test/templates/template.html'
			call = svgAssets.findAndReplace path, assetsFiles
			originalFile = fs.readFileSync path, 'UTF-8'

			expect(call).to.equal originalFile
