'use strict'

sharedObjects = require './shared-objects'

module.exports = class OptionsManager

	constructor: ->
		@logs = null
		@shared = new sharedObjects()
		@shared.logs = @shared.logs()
		@shared.defaultOptions = @shared.defaultOptions()
		@shared.options = @shared.defaultOptions

	init: (options) ->

		retObject =
			success: true
			shared: @shared

		if options
			@shared.options = options
		else
			@shared.logs.warnings.push "No options found -> defaults options have been used instead"

		@shared.options.logLevels = @checkOptionsWithDefaults 'logLevels'
		@shared.options.templatesExt = @checkOptionsWithDefaults 'templatesExt', true
		@shared.options.assetsExt = @checkOptionsWithDefaults 'assetsExt', true
		# deactivated for now --> @shared.options.matchTags = @checkOptionsWithDefaults 'matchTags'
		@shared.options.preserveRoot ?= @shared.defaultOptions.preserveRoot

		unless @shared.options.directory and typeof @shared.options.directory is 'string'
			prefix = 'No directory specified -> '
			if @shared.options.preserveRoot
				@shared.logs.errors.globalMessages.push "#{ prefix }processing aborted"
				retObject.success = false
				return retObject
			else
				@shared.options.directory = @shared.optionsDefinitions.directory.defaultValue
				@shared.logs.warnings.push "#{prefix}the root of your project has been used to find <svga> tags"


		unless @shared.options.assets and typeof @shared.options.assets is 'string'
			prefix = 'No assets folder specified -> '
			if @shared.options.preserveRoot
				@shared.logs.errors.globalMessages.push "#{ prefix }processing aborted"
				retObject.success = false
				return retObject
			else
				@shared.options.assets = @shared.optionsDefinitions.assets.defaultValue
				@shared.logs.warnings.push "#{prefix}the root of your project has been used to find matching files"


		unless @shared.options.outputDirectory and typeof @shared.options.outputDirectory is 'string'
			@shared.logs.warnings.push """
			  No output directory specified -> template source files will be replaced
			"""

		return retObject



	#Check validity of specific options towards default ones
	checkOptionsWithDefaults : (option, acceptAny) ->

		sharedOptions = @shared.options[option]
		defaultOptions = @shared.defaultOptions[option]
		optionIsString = typeof sharedOptions is 'string'
		optionIsBoolean = typeof sharedOptions is 'boolean'
		optionIsNumber = !isNaN parseFloat(sharedOptions) and isFinite sharedOptions
		optionIsArray = Array.isArray sharedOptions
		defaultOptionIsArray = Array.isArray defaultOptions
		optionsToMatch = if optionIsString then [sharedOptions] else sharedOptions
		arrayValuesMatch = @checkArrayMatch optionsToMatch, defaultOptions

		switch true
			# is a string and accept any value
			when optionIsString and acceptAny
			then optionsToMatch

			# is a string and part of authorized values
			when optionIsString and arrayValuesMatch
			then optionsToMatch

			# is a string but not part of authorized values
			when optionIsString and !arrayValuesMatch
			then @returnOptionsAndWarning option

			# is a an array and accept any values
			when optionIsArray and acceptAny
			then sharedOptions

			# is a an array but no values part of authorized values
			when optionIsArray and !arrayValuesMatch
			then @returnOptionsAndWarning option

			# is boolean or numeric value but an array is expected
			when (optionIsBoolean or optionIsNumber) and defaultOptionIsArray and !arrayValuesMatch
				@returnOptionsAndWarning option

			when !sharedOptions?
				defaultOptions

			else
				sharedOptions


	#loop for values in array and check that all values matches
	checkArrayMatch : (values, matches) ->
		check = false
		if !values?.length
			return check
		for value in values
			check = true if matches.indexOf(value) > -1
		return check

	# Warn and return defaults options
	returnOptionsAndWarning : (options) ->
		@shared.logs.warnings.push "Wrong #{ options } options -> default ones will be used instead"
		@shared.defaultOptions[options]
