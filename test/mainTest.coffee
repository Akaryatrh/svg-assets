SvgAssets = require '../src/main'
OptionsManager = require '../src/options-manager'
Logger = require '../src/logger'
chai = require 'chai'
sinon = require 'sinon'
fs = require 'fs'
mkdirp = require 'mkdirp'

expect = chai.expect
chai.should()


module.exports = run: ->

	svgAssets = null

	getInstance = (instance) ->
		if instance instanceof SvgAssets
			return svgAssets
		else
			return new SvgAssets

	beforeEach ->
		svgAssets = getInstance svgAssets

	afterEach ->
		svgAssets = null

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


	describe '@process', ->

		it 'should be a function', ->
			expect(svgAssets.process).to.be.a 'function'

		it """
			should call option manager to init options
				and set shared options
			""", ->
			spy = sinon.spy svgAssets._optionsManager, 'init'
			sinon.stub svgAssets._logger, 'log', -> return null
			svgAssets.process()
			sharedOptions =
				defaultOptions:
					assetsExt: ["svg"]
					logLevels: ["warning", "error", "info"]
					preserveRoot: true
					templatesExt: ["html", "htm", "hbs", "handlebars"]
				logs:
					errors:
						globalMessages: ["No directory specified -> processing aborted"]
						missingFiles: []
					infos: []
					process:
						filesLength: 0
						tags: 0
					startDate: 0
					warnings: ["No options found -> defaults options have been used instead"]
				options:
					assetsExt: ["svg"]
					logLevels: ["warning", "error", "info"]
					preserveRoot: true
					templatesExt: ["html", "htm", "hbs", "handlebars"]

			expect(spy.called).to.equal true
			expect(svgAssets.shared.defaultOptions).to.deep.equal sharedOptions.defaultOptions
			expect(svgAssets.shared.logs).to.deep.equal sharedOptions.logs
			expect(svgAssets.shared.options).to.deep.equal sharedOptions.options
			svgAssets._optionsManager.init.restore()
			svgAssets._logger.log.restore()

		it """
			should call when options are successfully initiated:
				@walk twice
				@findAndReplace twice
				@logger.log once
			""", ->
			initOptions =
				success: true
				shared:
					options:
						directory: 'foo'
						assets: 'bar'
						assetsExt: ["svg"]
						logLevels: ["warning", "error", "info"]
						preserveRoot: true
						templatesExt: ["html", "htm", "hbs", "handlebars"]
			replaceFunc = ->
				return initOptions
			walkCb = ->
				return ['foo', 'bar']
			findAndReplaceCb = ->
				return 'done'
			loggerCb = ->
				return 'log'

			sinon.stub svgAssets._optionsManager, 'init', replaceFunc
			stubWalk = sinon.stub svgAssets, 'walk', walkCb
			stubFindReplace = sinon.stub svgAssets, 'findAndReplace', findAndReplaceCb
			stubLogger = sinon.stub svgAssets._logger, 'log', loggerCb
			svgAssets.process()

			expect(stubWalk.callCount).to.equal 2
			expect(stubFindReplace.callCount).to.equal 2
			expect(stubLogger.callCount).to.equal 1



	describe '@rfds', ->


		it 'should try to read synchronously an accessible svg file and should return its content', ->
			mock ="""
<svg height="400" width="450">
	<path id="lineAB" d="M 100 350 l 150 -300" stroke="red" stroke-width="3" fill="none" />
</svg>
			"""
			path = './test/assets/file.svg'

			expect(svgAssets.rfds).to.be.a 'function'
			expect(svgAssets.rfds(path, 'file')).to.equal mock


		it 'should return null and push error in global log messages when file is missing', ->
			path = './test/assets/fake.svg'
			svgAssets.shared =
				logs:
					errors:
						globalMessages: []

			expect(svgAssets.rfds(path, 'file')).to.be.null
			expect(svgAssets.shared.logs.errors.globalMessages[0]).to.match /ENOENT/
			expect(svgAssets.shared.logs.errors.globalMessages[0]).to.match /\.\/test\/assets\/fake.svg/
			expect(svgAssets.shared.logs.errors.globalMessages).to.have.lengthOf(1)


	describe '@checkIfDir', ->

		it 'should return true when file is a directory', ->
			path = './test'

			expect(svgAssets.checkIfDir).to.be.a 'function'
			expect(svgAssets.checkIfDir(path)).to.be.true

		it 'should return false when file is not a directory', ->
			path = './test/assets/file.svg'

			expect(svgAssets.checkIfDir(path)).to.be.false

		it 'should return null and push error in global log messages when folder is missing', ->
			path = './fake_folder/'
			svgAssets.shared =
				logs:
					errors:
						globalMessages: []
			err = ["Error: ENOENT, no such file or directory './fake_folder/'"]

			expect(svgAssets.checkIfDir(path)).to.be.null
			expect(svgAssets.shared.logs.errors.globalMessages[0]).to.match /ENOENT/
			expect(svgAssets.shared.logs.errors.globalMessages[0]).to.match /\.\/fake_folder/
			expect(svgAssets.shared.logs.errors.globalMessages).to.have.lengthOf(1)





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
			path = './test/ass/emptySub'
			files = []
			extensions = ['svg']

			expect(svgAssets.walk(path, extensions)).to.include.members files



	describe '@createDirIfNotExists', ->

		stubMkdirp = null

		beforeEach ->
			stubMkdirp = sinon.stub mkdirp, 'sync'

		afterEach ->
			mkdirp.sync.restore()

		it 'should return true when mkdirp succeed', ->
			stubMkdirp.returns true
			expect(svgAssets.createDirIfNotExists('path/sub/sub-sub/test')).to.equal true

		it 'should return null when mkdirp throws an error', ->
			err =
				message: 'test'
			stubMkdirp.throws err
			call = svgAssets.createDirIfNotExists('path/sub/sub-sub/test')
			expect(svgAssets.shared.logs.errors.globalMessages).to.members ['Error: test']
			expect(call).to.equal null




	describe '@findAndReplace', ->
		spyCreateDir =
		stubRead =
		stubWrite =
		stubMkdirp =
		replaceMkdirp =
		templateContent =
		fileContent =
		processed =
		assetsFiles =
		path =
		null

		beforeEach ->
			templateContent = '<div><svga>myfile</svga></div>'
			fileContent = '<svg></svg>'
			processed = '<div><svg></svg></div>'
			assetsFiles = ['test/myfile.svg']
			path = 'test/mytemplate.html'
			# Provide options while they have not been initialied by process function
			svgAssets.shared.options =
				directory: 'test'
				templatesExt: ['html', 'htm', 'hbs', 'handlebars']
				outputDirectory: null
				assets: 'test'
				assetsExt: ['svg']
				logLevels: ['warning', 'error', 'info']
				preserveRoot: true

			#Stubs & spies
			spyCreateDir = sinon.spy svgAssets, 'createDirIfNotExists'
			stubRead = sinon.stub svgAssets, 'rfds'
			stubWrite = sinon.stub fs, 'writeFileSync'
			replaceMkdirp = ->
				return true
			stubMkdirp = sinon.stub mkdirp, 'sync', replaceMkdirp

		afterEach ->
			# restore stubbed & spied methods
			svgAssets.createDirIfNotExists.restore()
			svgAssets.rfds.restore()
			fs.writeFileSync.restore()
			mkdirp.sync.restore()


		it """
			should replace a <svga> tag with an existing matching file
			""", ->

			stubRead.withArgs('test/mytemplate.html', 'file').returns templateContent
			stubRead.withArgs('test/myfile.svg', 'file').returns fileContent

			call = svgAssets.findAndReplace path, assetsFiles

			# template and svg file should be read
			expect(stubRead.callCount).to.equal 2
			# final directory should exist or be created
			expect(spyCreateDir.callCount).to.equal 1
			# final file should be written
			expect(stubWrite.callCount).to.equal 1
			expect(stubWrite.calledWithExactly(path, processed)).to.equal true
			# File content should be properly processed
			expect(call).to.equal processed

		it """
			should replace a <svga> tag with an existing matching file
				and output it on a different location
			""", ->

			svgAssets.shared.options.outputDirectory = 'foo'

			stubRead.withArgs('test/mytemplate.html', 'file').returns templateContent
			stubRead.withArgs('test/myfile.svg', 'file').returns fileContent

			call = svgAssets.findAndReplace path, assetsFiles

			# template and svg file should be read
			expect(stubRead.callCount).to.equal 2
			# final directory should exist or be created
			expect(spyCreateDir.callCount).to.equal 1
			# final file should be written
			expect(stubWrite.callCount).to.equal 1
			expect(stubWrite.calledWithExactly('foo/mytemplate.html', processed)).to.equal true
			# File content should be properly processed
			expect(call).to.equal processed

		it """
			should clean the svg content from unwanted tags & comments
				and keep its properties
			""", ->

			fileContent = """
			<?xml version="1.0" encoding="UTF-8" standalone="no"?>
			<!-- Created with Inkscape (http://www.inkscape.org/) -->

			<svg
			   xmlns:dc="http://purl.org/dc/elements/1.1/"
			   xmlns:cc="http://creativecommons.org/ns#"
			   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			   xmlns:svg="http://www.w3.org/2000/svg"
			   xmlns="http://www.w3.org/2000/svg"
			   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
			   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
			   id="svg2"
			   version="1.1"
			   inkscape:version="0.47 r22583"
			   width="2182.0059"
			   height="4578.1162"
			   sodipodi:docname="IPhone_5.png">
			</svg>
			"""

			processed = """
			<div>


			<svg
			   xmlns:dc="http://purl.org/dc/elements/1.1/"
			   xmlns:cc="http://creativecommons.org/ns#"
			   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			   xmlns:svg="http://www.w3.org/2000/svg"
			   xmlns="http://www.w3.org/2000/svg"
			   xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd"
			   xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape"
			   id="svg2"
			   version="1.1"
			   inkscape:version="0.47 r22583"
			   width="2182.0059"
			   height="4578.1162"
			   sodipodi:docname="IPhone_5.png">
			</svg></div>
			"""

			stubRead.withArgs('test/mytemplate.html', 'file').returns templateContent
			stubRead.withArgs('test/myfile.svg', 'file').returns fileContent

			call = svgAssets.findAndReplace path, assetsFiles
			# File content should be properly processed
			expect(call).to.equal processed


		it """
			should leave untouched the template file
				if not matching svg file found
			""", ->

			stubRead.withArgs('test/mytemplate.html', 'file').returns templateContent
			stubRead.withArgs('test/myfile.svg', 'file').returns null

			call = svgAssets.findAndReplace path, assetsFiles

			# template and svg file should be read
			expect(stubRead.callCount).to.equal 2
			# final directory should exist or be created
			expect(spyCreateDir.callCount).to.equal 0
			# final file shouldn't be written
			expect(stubWrite.callCount).to.equal 0
			# File content shouldn't be processed
			expect(call).to.equal templateContent

		it """
			should leave untouched the template file
				if not matching svga tag found
			""", ->

			templateContent = '<div></div>'

			stubRead.withArgs('test/mytemplate.html', 'file').returns templateContent

			call = svgAssets.findAndReplace path, assetsFiles

			# template should be read
			expect(stubRead.callCount).to.equal 1
			# final directory should exist or be created
			expect(spyCreateDir.callCount).to.equal 0
			# final file shouldn't be written
			expect(stubWrite.callCount).to.equal 0
			# File content shouldn't be processed
			expect(call).to.equal templateContent


	return
