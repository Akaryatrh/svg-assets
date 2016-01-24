chai = require 'chai'
sinon = require 'sinon'
Util = require 'util'
CliParser = require '../src/cli-parser'
SharedObjects = require '../src/shared-objects'
commander = require 'commander'
fs = require 'fs'


expect = chai.expect
chai.should()

module.exports = run: ->

	cliParser = null
	sharedObjects = null

	beforeEach ->
		cliParser = new CliParser
		sharedObjects = new SharedObjects

	describe '@constructor', ->

		it 'should have created an instance of the SharedObjects', ->
			expect(sharedObjects).to.be.an 'object'
			expect(sharedObjects).to.be.an.instanceof SharedObjects


	describe '@initCommander', ->

		it 'should be a function', ->
			expect(cliParser.initCommander).to.be.a 'function'

		it 'should returns help when no options given', ->
			replaceFunc = ->
				'help output'
			sinon.stub commander, 'outputHelp', replaceFunc
			expect(cliParser.initCommander([])).to.equal 'help output'
			commander.outputHelp.restore()

		it 'should returns empty options with "--run" argument', ->
			args = [null, null, '--run']
			expect(cliParser.initCommander(args)).to.deep.equal {}

	describe '@getVersion', ->

		it 'should be a function', ->
			expect(cliParser.getVersion).to.be.a 'function'

		it 'should return current version of svg-assets package', ->
			packageFile = fs.readFileSync './package.json', 'UTF-8'
			packageVersion = JSON.parse(packageFile).version
			expect(cliParser.getVersion()).to.equal packageVersion



	describe '@matchArguments', ->

		it 'should be a function', ->
			expect(cliParser.matchArguments).to.be.a 'function'

		it 'should return an empty object if null object given', ->
			options = {}
			expect(cliParser.matchArguments(options)).to.deep.equal {}

		it 'should return an empty object if unknown option given', ->
			options =
				fake_option: true
			expect(cliParser.matchArguments(options)).to.deep.equal {}

		it 'should return known options if unknown option is part of known options given', ->
			options =
				fake_option: true
				directory: 'test'
				assets: 'test'
				assetsExt: ['svg']
			expected =
				assets: 'test'
				assetsExt: ['svg']
				directory: 'test'
			expect(cliParser.matchArguments(options)).to.deep.equal expected

		it """
			should convert to boolean preserveRoot option value when it's set to 'false'
				and automatically add directory and assets option
			""", ->
			options =
				preserveRoot: 'false'
			expected =
				assets: '.'
				directory: '.'
				preserveRoot: false

			expect(cliParser.matchArguments(options)).to.deep.equal expected

	return
