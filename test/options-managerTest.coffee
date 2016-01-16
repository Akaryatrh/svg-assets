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
			expect(sharedObjects).to.be.an 'object'
			expect(sharedObjects).to.be.an.instanceof SharedObjects


		it 'should have registered a shared logs object', ->
			sharedLogs = sharedObjects.logs()
			expect(sharedLogs).to.be.an 'object'


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
				logLevels: ['unknown']
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


	# TODO describe '@init', ->


	return