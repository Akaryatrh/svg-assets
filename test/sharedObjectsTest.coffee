chai = require 'chai'
sinon = require 'sinon'
sharedObjects = require '../src/shared-objects'

expect = chai.expect
chai.should()

module.exports = run: ->

	shared = null
	clock = sinon.useFakeTimers()

	beforeEach ->
		shared = new sharedObjects




	describe '@logs', ->

		it 'should be a function', ->
			expect(shared.logs).to.be.a 'function'

		it 'should return a predefined object', ->

			mock =
				errors:
					missingFiles: []
					globalMessages: []
				warnings: []
				infos: []
				process:
					tags: 0
					filesLength: 0
				startDate: Date.now()

			expect(shared.logs()).to.deep.equal mock


	describe '@defaultOptions', ->

		it 'should be a function', ->
			expect(shared.defaultOptions).to.be.a 'function'

		it 'should return a predefined object', ->

			mock =
				templatesExt: ['html', 'htm', 'hbs', 'handlebars']
				assetsExt: ['svg']
				logLevels: ['warning', 'error', 'info']
				preserveRoot: true

			expect(shared.defaultOptions()).to.deep.equal mock


	describe '@optionsDefinitions', ->

		it 'should be a predefined object', ->
			expect(shared.optionsDefinitions).to.be.an 'object'

		it 'should have default values for each option', ->
			for option in shared.optionsDefinitions
				testIfdefaultValue = option.hasOwnProperty 'defaultValue'
				expect(testIfdefaultValue).to.be.true

		it 'should have a command definition for each option', ->
			for option in shared.optionsDefinitions
				testIfCommand = option.hasOwnProperty 'commands'
				expect(testIfCommand).to.be.true

		it 'should have a command description for each option', ->
			for option in shared.optionsDefinitions
				testIfCommandDesc = option.hasOwnProperty 'commandDescription'
				expect(testIfCommandDesc).to.be.true

	return
