chai = require 'chai'
sinon = require 'sinon'
Util = require 'util'
Logger = require '../src/logger'
sharedObjects = require '../src/shared-objects'

expect = chai.expect
chai.should()

module.exports = run: ->

	clock = sinon.useFakeTimers()

	logger = null
	beforeEach ->
		logger = new Logger

	describe '@constructor', ->

		it 'should have a shorthand method to console.log', ->
			mock = console.log

			expect(logger.cl).to.be.a 'function'
			expect(logger.cl).to.equal mock


	describe '@dateNow', ->


		it 'should be a function', ->
			expect(logger.dateNow).to.be.a 'function'

		it 'should format properly the current date and time', ->
			mock = '1970-01-01 00:00:00 UTC'

			expect(logger.dateNow).to.be.a 'function'
			expect(logger.dateNow()).to.equal mock


	describe '@log', ->

		replaceFunc = ->
			return

		shared = null

		beforeEach ->
			shared = new sharedObjects()
			sinon.stub logger, 'cl', replaceFunc()

		it 'should be a function', ->
			expect(logger.log).to.be.a 'function'

		it 'without options, should push proper warnings in logs', ->

			warnings = [
				"""
				No file processed :
				\t∷ Processing could have been aborted due to wrong options definitions
				\t∷ No <svga> tags could have been found
				\t∷ Found <svga> tags might have not matched any files
				"""
			]
			returnedLogs = logger.log(shared)
			expect(returnedLogs.logs.warnings).to.deep.members warnings

		it "shouldn't find any missing files", ->

			missingFiles = []
			returnedLogs = logger.log(shared)

			expect(returnedLogs.logs.errors.missingFiles).to.deep.equal missingFiles

		it 'should have called console log', ->
			logger.log(shared)
			#TODO : must be fixed
			# The test pass even if the expect returns false, but an error will be thrown
			process.on 'exit', ->
				expect(logger.cl.calledWith(sinon.match('svgAssets did its job in'))).to.equal true

	return