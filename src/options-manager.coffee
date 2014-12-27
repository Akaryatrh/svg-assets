shared = require './shared-objects'

module.exports = class OptionsManager

	constructor: (@options)->
		#console.log shorthand
		@cl = console.log



	init: ->

		# No options defined -> fallback to default ones
		if @options
			shared.options = @options
		else
			shared.options = shared.defaultOptions
			shared.logs.warnings.push "No options found -> defaults options have been used instead"


		shared.options.logLevels = @checkOptionsWithDefaults 'logLevels'
		shared.options.templatesExt = @checkOptionsWithDefaults 'templatesExt', true
		shared.options.assetsExt = @checkOptionsWithDefaults 'assetsExt', true
		# deactivated for now --> shared.options.matchTags = @checkOptionsWithDefaults 'matchTags'
		shared.options.preserveRoot ?= shared.defaultOptions.preserveRoot

		unless shared.options.directory
			prefix = 'No directory specified -> '
			if shared.options.preserveRoot?
				shared.logs.errors.globalMessages.push "#{ prefix }processing aborted"
				return false
			else
				shared.options.directory = '.'
				shared.logs.warnings.push "#{prefix}the root of your project has been used to find <svga> tags"


		unless shared.options.assets
			prefix = 'No assets folder specified -> '
			if shared.options.preserveRoot?
				shared.logs.errors.globalMessages.push "#{ prefix }processing aborted"
				return false
			else
				shared.options.assets = '.'
				shared.logs.warnings.push "#{prefix}the root of your project has been used to find matching files"

		return true



	#Check validity of specific options towards default ones
	checkOptionsWithDefaults : (options, acceptAny) ->
		switch
			# is a string and accept any value
			when typeof shared.options[options] is 'string' and acceptAny
			then [shared.options[options]]

			# is a string and part of authorized values
			when typeof shared.options[options] is 'string' and
			shared.defaultOptions[options].indexOf(shared.options[options]) > -1
			then [shared.options[options]]

			# is a string but not part of authorized values
			when typeof shared.options[options] is 'string' and
			shared.defaultOptions[options].indexOf(shared.options[options]) is -1
			then @returnOptionsAndWarning options

			# is a an array and accept any values
			when Array.isArray(shared.options[options]) and acceptAny
			then shared.options[options]

			# is a an array but no values part of authorized values
			when Array.isArray(shared.options[options]) and
			@checkArrayMatch(shared.options[options], shared.defaultOptions[options]) is false
			then @returnOptionsAndWarning options

			when !shared.options[options]?
			then shared.defaultOptions[options]

			else shared.options[options]


	#loop for values in array and check that all values matches
	checkArrayMatch : (values, matches) ->
		check = false
		for value in values
			check = true if matches.indexOf(value) > -1
		check

	# Warn and return defaults options
	returnOptionsAndWarning : (options) ->
		shared.logs.warnings.push "Wrong #{ options } options -> default ones will be used instead"
		shared.defaultOptions[options]