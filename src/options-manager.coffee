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

		# No options defined -> fallback to default ones
		if options
			@shared.options = options
		else
			@shared.options = @shared.defaultOptions()
			@shared.logs.warnings.push "No options found -> defaults options have been used instead"


		@shared.options.logLevels = @checkOptionsWithDefaults 'logLevels'
		@shared.options.templatesExt = @checkOptionsWithDefaults 'templatesExt', true
		@shared.options.assetsExt = @checkOptionsWithDefaults 'assetsExt', true
		# deactivated for now --> @shared.options.matchTags = @checkOptionsWithDefaults 'matchTags'
		@shared.options.preserveRoot ?= @shared.defaultOptions.preserveRoot

		unless @shared.options.directory
			prefix = 'No directory specified -> '
			if @shared.options.preserveRoot
				@shared.logs.errors.globalMessages.push "#{ prefix }processing aborted"
				retObject.success = false
				return retObject
			else
				@shared.options.directory = '.'
				@shared.logs.warnings.push "#{prefix}the root of your project has been used to find <svga> tags"


		unless @shared.options.assets
			prefix = 'No assets folder specified -> '
			if @shared.options.preserveRoot
				@shared.logs.errors.globalMessages.push "#{ prefix }processing aborted"
				retObject.success = false
				return retObject
			else
				@shared.options.assets = '.'
				@shared.logs.warnings.push "#{prefix}the root of your project has been used to find matching files"

		return retObject



	#Check validity of specific options towards default ones
	checkOptionsWithDefaults : (options, acceptAny) ->
		switch
			# is a string and accept any value
			when typeof @shared.options[options] is 'string' and acceptAny
			then [@shared.options[options]]

			# is a string and part of authorized values
			when typeof @shared.options[options] is 'string' and
			@checkArrayMatch([@shared.options[options]], @shared.defaultOptions[options])
			then [@shared.options[options]]

			# is a string but not part of authorized values
			when typeof @shared.options[options] is 'string' and
			!@checkArrayMatch(@shared.options[options], @shared.defaultOptions[options])
			then @returnOptionsAndWarning options

			# is a an array and accept any values
			when Array.isArray(@shared.options[options]) and acceptAny
			then @shared.options[options]

			# is a an array but no values part of authorized values
			when Array.isArray(@shared.options[options]) and
			!@checkArrayMatch(@shared.options[options], @shared.defaultOptions[options])
			then @returnOptionsAndWarning options

			when !@shared.options[options]?
			then @shared.defaultOptions[options]

			else @shared.options[options]


	#loop for values in array and check that all values matches
	checkArrayMatch : (values, matches) ->
		check = false
		for value in values
			check = true if matches.indexOf(value) > -1
		check

	# Warn and return defaults options
	returnOptionsAndWarning : (options) ->
		@shared.logs.warnings.push "Wrong #{ options } options -> default ones will be used instead"
		@shared.defaultOptions[options]