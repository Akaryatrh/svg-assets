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
			sinon.stub logger, 'cl', replaceFunc

		it 'should be a function', ->
			expect(logger.log).to.be.a 'function'

		it 'without options, should push proper warnings in logs', ->

			warnings = [
				"""
				No file processed :
				\t∷ Processing could have been aborted due to wrong options usage or unexpected error
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
			options =
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

			returnedLogs = logger.log(options)
			expect(returnedLogs.logs.warnings).to.deep.members warnings

		it 'with specific options, should push proper infos in logs', ->

			infos = ['1 <svga> tag(s) have been processed in 1 file(s)']
			options =
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

			returnedLogs = logger.log(options)
			expect(returnedLogs.logs.infos).to.deep.members infos

		it 'with specific options, should push proper errors in logs', ->

			errors = ["""
			2 assets file(s) not found or not readable:
			 "file1.svg","file2.svg"
			"""]
			options =
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

			returnedLogs = logger.log(options)
			expect(returnedLogs.logs.errors.globalMessages).to.deep.members errors

		it 'should have called console log', ->
			sinon.stub logger.log()
			expect(logger.cl.calledWith(sinon.match('svgAssets did its job in'))).to.equal true



	describe '@coloringOutput', ->

		it 'should be a function', ->
			expect(logger.coloringOutput).to.be.a 'function'

		it 'should output a colored warning message with type "warning" and a message', ->
			type = 'warning'
			message = 'current warning message'
			expected = "\u001b[33m\n→ Warning: \u001b[39mcurrent warning message"

			expect(logger.coloringOutput(type, message)).to.equal expected

		it 'should output a colored error message with type "error" and a message', ->
			type = 'error'
			message = 'current error message'
			expected = "\u001b[31m\n→ Error: \u001b[39mcurrent error message"

			expect(logger.coloringOutput(type, message)).to.equal expected

		it 'should output a colored info message with type "info" and a message', ->
			type = 'info'
			message = 'current info message'
			expected = "\u001b[32m\n→ Info: \u001b[39mcurrent info message"

			expect(logger.coloringOutput(type, message)).to.equal expected

		it 'should output a colored exec message with type "exec" and no message', ->
			type = 'exec'
			expected = "\u001b[90m\n→ svgAssets did its job in 0ms\u001b[39m"

			expect(logger.coloringOutput(type)).to.equal expected

	return
