chai = require 'chai'
sinon = require 'sinon'
sharedObjects = require '../src/shared-objects'

expect = chai.expect
chai.should()

module.exports = run: ->


	it 'should be a function', ->
		expect(sharedObjects).to.be.a 'function'

	it 'should have a preset logs object', ->

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


		shared = sharedObjects()
		expect(shared.logs).to.be.an 'object'
		expect(shared.logs).to.deep.equal mock



	it 'should have a preset defaultOptions object', ->

		mock =
			templatesExt: ['html', 'htm', 'hbs', 'handlebars']
			assetsExt: ['svg']
			logLevels: ['warning', 'error', 'info']
			preserveRoot: true

		shared = sharedObjects()
		expect(shared.defaultOptions).to.be.an 'object'
		expect(shared.defaultOptions).to.deep.equal mock

	return