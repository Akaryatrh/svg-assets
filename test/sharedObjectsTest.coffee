sharedPath = '../src/shared-objects'
chai = require 'chai'
sinon = require 'sinon'

expect = chai.expect
chai.should()

module.exports = ->

	# Shared objects is a singleton, and has been modified by other modules.
	# Before testing it, we must remove it from require cache
	delete require.cache[require.resolve(sharedPath)]
	clock = sinon.useFakeTimers()
	shared = require sharedPath


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

		expect(shared.logs).to.be.an 'object'
		expect(shared.logs).to.deep.equal mock