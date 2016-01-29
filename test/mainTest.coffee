SvgAssets = require '../src/main'
OptionsManager = require '../src/options-manager'
Logger = require '../src/logger'
chai = require 'chai'
sinon = require 'sinon'
fs = require 'fs'

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
			err = ["Error: ENOENT, no such file or directory './test/assets/fake.svg'"]

			expect(svgAssets.rfds(path, 'file')).to.be.null
			expect(svgAssets.shared.logs.errors.globalMessages).to.deep.members err


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
			expect(svgAssets.shared.logs.errors.globalMessages).to.deep.members err





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
			# Provide options while they have not been initialied by process function
			svgAssets.shared.options =
				directory: './test'
				templatesExt: ['html', 'htm', 'hbs', 'handlebars']
				outputDirectory: ''
				assets: './test'
				assetsExt: ['svg']
				logLevels: ['warning', 'error', 'info']
				preserveRoot: true


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

	return
