chai = require 'chai'
sinon = require 'sinon'
Util = require 'util'
Logger = require '../src/logger'

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

		beforeEach ->
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
			returnedLogs = logger.log()
			expect(returnedLogs.logs.warnings).to.deep.members warnings

		it "without options, shouldn't find any missing files", ->

			missingFiles = []
			returnedLogs = logger.log()

			expect(returnedLogs.logs.errors.missingFiles).to.deep.equal missingFiles

		it 'with specific options, should not push warnings in logs', ->

			warnings = []
			options = {
				logs:
					errors:
						missingFiles: []
						globalMessages: []
					warnings: []
					infos: []
					process:
						tags: 1
						filesLength: 1
					startDate: Date.now()
			}
			returnedLogs = logger.log(options)
			expect(returnedLogs.logs.warnings).to.deep.members warnings

		it 'with specific options, should push proper infos in logs', ->

			infos = ['1 <svga> tag(s) have been processed in 1 file(s)']
			options = {
				logs:
					errors:
						missingFiles: []
						globalMessages: []
					warnings: []
					infos: []
					process:
						tags: 1
						filesLength: 1
					startDate: Date.now()
			}
			returnedLogs = logger.log(options)
			expect(returnedLogs.logs.infos).to.deep.members infos

		it 'with specific options, should push proper errors in logs', ->

			errors = ["""
			2 assets file(s) not found or not readable:
			 "file1.svg","file2.svg"
			"""]
			options = {
				logs:
					errors:
						missingFiles: ['file1', 'file2']
						globalMessages: []
					warnings: []
					infos: []
					process:
						tags: 0
						filesLength: 0
					startDate: Date.now()
			}
			returnedLogs = logger.log(options)
			expect(returnedLogs.logs.errors.globalMessages).to.deep.members errors


		it 'should have called console log', ->
			logger.log()
			expect(logger.cl.calledWith(sinon.match('svgAssets did its job in'))).to.equal true

	return