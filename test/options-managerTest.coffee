chai = require 'chai'
sinon = require 'sinon'
Util = require 'util'
OptionsManager = require '../src/options-manager'
SharedObjects = require '../src/shared-objects'

expect = chai.expect
chai.should()

module.exports = run: ->

	sharedObjects = null
	optionsManager = null

	beforeEach ->
		optionsManager = new OptionsManager
		sharedObjects = new SharedObjects


	describe '@constructor', ->

		it 'should have created an instance of the SharedObjects', ->
			expect(optionsManager.shared).to.be.an 'object'
			expect(optionsManager.shared).to.be.an.instanceof SharedObjects


		it 'should have registered a shared logs object', ->
			sharedLogs = sharedObjects.logs()
			expect(optionsManager.shared.logs).to.be.an 'object'
			expect(optionsManager.shared.logs).to.deep.equal sharedLogs

		it 'should have registered a shared options object', ->
			sharedOptions = sharedObjects.defaultOptions()
			expect(optionsManager.shared.options).to.be.an 'object'
			expect(optionsManager.shared.options).to.deep.equal sharedOptions

	describe 'init', ->

		it 'should be a function', ->
			expect(optionsManager.init).to.be.a 'function'

		it 'should keep default options for shared options when no options given', ->
			optionsManager.init()
			defautOptions = sharedObjects.defaultOptions()
			expect(optionsManager.shared.options).to.deep.equal defautOptions

		it 'should push warn log about default options when no options given', ->
			warn = ["No options found -> defaults options have been used instead"]
			optionsManager.init()
			expect(optionsManager.shared.logs.warnings).to.include.members warn

		it 'should assign new options to shared options', ->
			options =
				directory: 'test',
				templatesExt: [ 'html' ],
				assets: 'test'
				assetsExt: [ 'svg' ]
				logLevels: [ 'warning']
				preserveRoot: true
			optionsManager.init(options)
			expect(optionsManager.shared.options).to.deep.equal options

		it 'should push error log about directory option when not specified with preserve-root option set to true', ->
			error = ["No directory specified -> processing aborted"]
			optionsManager.init()
			expect(optionsManager.shared.logs.errors.globalMessages).to.include.members error

		it """
			should push warn log about directory option when not specified with preserve-root option set to false
				and set predefined options for directory
			""", ->
			warn = ["No directory specified -> the root of your project has been used to find <svga> tags"]
			options =
				preserveRoot: false
			defaultDirectory = sharedObjects.optionsDefinitions.directory.defaultValue
			optionsManager.init options
			expect(optionsManager.shared.logs.warnings).to.include.members warn
			expect(optionsManager.shared.options.directory).to.equal defaultDirectory

		it 'should push error log about assets directory option when not specified with preserve-root option set to true', ->
			options =
				directory: 'test'
			error = ["No assets folder specified -> processing aborted"]
			optionsManager.init(options)
			expect(optionsManager.shared.logs.errors.globalMessages).to.include.members error

		it """
			should push warn log about assets directory option when not specified with preserve-root option set to false
				and set predefined options for assets directory
			""", ->
			warn = ["No assets folder specified -> the root of your project has been used to find matching files"]
			options =
				preserveRoot: false
			defaultAssets = sharedObjects.optionsDefinitions.assets.defaultValue
			optionsManager.init options
			expect(optionsManager.shared.logs.warnings).to.include.members warn
			expect(optionsManager.shared.options.assets).to.equal defaultAssets

		it 'should push warning log about output directory option when not specified', ->
			options =
				directory: 'test'
				assets: 'test'
			warn = ["No output directory specified -> template source files will be replaced"]
			optionsManager.init(options)
			expect(optionsManager.shared.logs.warnings).to.include.members warn


	describe '@returnOptionsAndWarning', ->

		it 'should be a function', ->
			expect(optionsManager.returnOptionsAndWarning).to.be.a 'function'

		it 'should push new warnings', ->
			options = 'preserveRoot'
			warnings = ["Wrong preserveRoot options -> default ones will be used instead"]
			optionsManager.returnOptionsAndWarning options
			expect(optionsManager.shared.logs.warnings).to.deep.members warnings

		it 'should return defaults options', ->
			options = 'preserveRoot'
			mock = true
			expect(optionsManager.returnOptionsAndWarning(options)).to.equal mock


	describe '@checkArrayMatch', ->

		it 'should be a function', ->
			expect(optionsManager.checkArrayMatch).to.be.a 'function'

		it 'should return true with an existing option', ->
			options = ['preserveRoot']
			defaultOptions = ['preserveRoot']
			expect(optionsManager.checkArrayMatch).to.be.a 'function'
			expect(optionsManager.checkArrayMatch(options, defaultOptions)).to.equal true

		it 'should return false with an unknown option', ->
			options = ['unknownOption']
			defaultOptions = ['preserveRoot']
			expect(optionsManager.checkArrayMatch(options, defaultOptions)).to.equal false


	describe '@checkOptionsWithDefaults', ->

		beforeEach ->
			optionsManager = new OptionsManager

		it 'should be a function', ->
			expect(optionsManager.checkOptionsWithDefaults).to.be.a 'function'

		it 'when option is string and any value accepted,
		it should return provided values', ->
			option = 'templatesExt'
			overrideOptions =
				templatesExt: 'html'
			optionsManager.shared.options = overrideOptions
			returnedValues = ['html']
			expect(optionsManager.checkOptionsWithDefaults(option, true)).to.deep.members returnedValues

		it 'when option is string, options match, but values are restricted,
		it should return provided values', ->
			option = 'templatesExt'
			overrideOptions =
				templatesExt: 'html'
			optionsManager.shared.options = overrideOptions
			returnedValues = ['html']
			expect(optionsManager.checkOptionsWithDefaults(option)).to.deep.members returnedValues

		it 'when option is string, but options mismatch and values are restricted,
		it should return default values and warn user', ->
			option = 'logLevels'
			overrideOptions =
				logLevels: 'unknown'
			optionsManager.shared.options = overrideOptions
			spy = sinon.spy(optionsManager, 'returnOptionsAndWarning')
			returnedValues = ['warning', 'error', 'info']
			expect(optionsManager.checkOptionsWithDefaults(option)).to.deep.members returnedValues
			expect(optionsManager.returnOptionsAndWarning.calledOnce).to.equal true

		it 'when option is an Array and any value accepted,
		it should return provided values', ->
			option = 'templatesExt'
			overrideOptions =
				templatesExt: ['html']
			optionsManager.shared.options = overrideOptions
			returnedValues = ['html']
			expect(optionsManager.checkOptionsWithDefaults(option, true)).to.deep.members returnedValues

		it 'when option is an Array but options mismatch and values are restricted,
		it should return default values and warn user', ->
			option = 'templatesExt'
			overrideOptions =
				templatesExt: ['php']
			optionsManager.shared.options = overrideOptions
			spy = sinon.spy(optionsManager, 'returnOptionsAndWarning')
			returnedValues = ['html', 'htm', 'hbs', 'handlebars']
			expect(optionsManager.checkOptionsWithDefaults(option)).to.deep.members returnedValues
			expect(optionsManager.returnOptionsAndWarning.calledOnce).to.equal true

		it 'when option has not been defined,
		it should return default values', ->
			option = 'logLevels'
			optionsManager.shared.options = {}
			returnedValues = ['warning', 'error', 'info']
			expect(optionsManager.checkOptionsWithDefaults(option)).to.deep.members returnedValues


	return
