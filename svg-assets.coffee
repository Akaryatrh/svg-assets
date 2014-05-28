fs = require 'fs'
colors = require 'colors'

module.exports = class SvgAssets

	constructor: (@options) ->
		@logs =
			errors:
				missingFiles: []
				globalMessages: []
			warnings: []
			infos: []
			process:
				tags: 0
				filesLength: 0

		#console.log shorthand
		@cl = console.log
		return


	manageOptions: ->

		defaultOptions =
			templatesExt: ['html', 'htm', 'hbs', 'handlebars']
			assetsExt: ['svg']
			logLevels: ['warning', 'error', 'info']
			#deactivated for now matchTags: ['svga']
			preserveRoot: true


		# No options defined -> fallback to default ones
		unless @options
			@options = defaultOptions
			@logs.warnings.push "No options found -> defaults options have been used instead"


		#Check validity of specific options towards default ones
		checkOptionsWithDefaults = (options) =>
			switch
				# is a string and part of authorized values
				when typeof @options[options] is 'string' and
				defaultOptions[options].indexOf(@options[options]) > -1
				then [@options[options]]

				# is a string but not part of authorized values
				when typeof @options[options] is 'string' and
				defaultOptions[options].indexOf(@options[options]) is -1
				then returnOptionsAndWarning options

				# is a an array but no values part of authorized values
				when Array.isArray(@options[options]) and
				checkArrayMatch(@options[options], defaultOptions[options]) is false
				then returnOptionsAndWarning options

				when !@options[options]?
				then defaultOptions[options]

				else @options[options]


		#loop for values in array and check that all values matches
		checkArrayMatch = (values, matches) ->
			check = false
			for value in values
				check = true if matches.indexOf(value) > -1
			check

		# Warn and return defaults options
		returnOptionsAndWarning = (options) =>
			@logs.warnings.push "Wrong #{ options } options -> default ones will be used instead"
			defaultOptions[options]


		@options.logLevels = checkOptionsWithDefaults 'logLevels'
		@options.templatesExt = checkOptionsWithDefaults 'templatesExt'
		@options.assetsExt = checkOptionsWithDefaults 'assetsExt'
		# deactivated for now @options.matchTags = checkOptionsWithDefaults 'matchTags'
		@options.preserveRoot ?= defaultOptions.preserveRoot

		unless @options.directory
			prefix = 'No directory specified -> '
			if @options.preserveRoot?
				@logs.errors.globalMessages.push "#{ prefix }processing aborted"
				return false
			else
				@options.directory = '.'
				@logs.warnings.push "#{prefix}the root of your project has been used to find <svga> tags"


		unless @options.assets
			prefix = 'No assets folder specified -> '
			if @options.preserveRoot?
				@logs.errors.globalMessages.push "#{ prefix }processing aborted"
				return false
			else
				@options.assets = '.'
				@logs.warnings.push "#{prefix}the root of your project has been used to find matching files"

		return true


	process: ->
		if @manageOptions()

			allFiles = @walk @options.directory, @options.templatesExt
			assetsFiles = @walk @options.assets, @options.assetsExt
			for file in allFiles
				@findAndReplace file, assetsFiles

		@log()


	#Date util
	dateNow: ->
		return new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '') + ' UTC'


	log: ->
		#Log header
		@cl " 𝘀𝘃𝗴 𝗮𝘀𝘀𝗲𝘁𝘀 Ξ #{ @dateNow() }"

		# Regular log
		if @logs.process.filesLength > 0
			@logs.infos.push "#{ @logs.process.tags } <svga> tags have been processed in #{@logs.process.filesLength} files"
		else
			@logs.warnings.push "No file processed (processing has been aborted or no matching <svga> tags have been found)"

		filenames = []
		# Assets error log
		for filename in @logs.errors.missingFiles
			filenames.push '"' + filename + '.svg"'
		if filenames.length
			@logs.errors.globalMessages.push "Assets file(s) #{ filenames.join(',') } not found or not readable"


		### OUTPUT ###

		# Warning log
		if @options.logLevels.indexOf "warning" > -1
			for warning in @logs.warnings
				@cl (' → Warning: ').yellow + warning

		# Info log
		if @options.logLevels.indexOf "info" > -1
			for info in @logs.infos
				@cl (' → Info: ').green + info

		# Global error log
		if @options.logLevels.indexOf "error" > -1
			for error in @logs.errors.globalMessages
				@cl (' → Error: ').red + error
		return


	# ReadFileSync
	rfs: (path) ->
		try
			response = fs.readFileSync path, 'UTF-8'

		catch err
			# Catch file not found error
			if err.code isnt 'ENOENT'
				#throw e
				@logs.errors.globalMessages.push err
			else
				response = null;

		response


	# List files recursively
	walk: (dir, ext)->

		files = []
		matcher = (fn) -> fn.match /// \.(#{ ext.join('|') }) ///

		_walk = (dir) ->
			unless fs.statSync(dir).isDirectory() then return files

			fns = fs.readdirSync dir
			for fn in fns
				fn = dir + '/' + fn
				if matcher fn then files.push fn
				if fs.statSync(fn).isDirectory() then _walk fn
			return files

		_walk dir


	#Find and replace <svga>
	findAndReplace: (path, assetsFiles) ->
		dataTemplate = @rfs path
		# We look for the tag <svga> in template
		# and will extract the filename and possible properties
		pattern = /(<svga(.*)>(.+)<\/svga>)/gi
		res = dataTemplate.replace pattern, ($0, originalString, properties, filename) =>
			# We want to replace <svga> tag with contents from matching svg file
			for asset in assetsFiles
				# we look for an asset with a path ending with filename
				pattern = ///\/#{filename}\.svg$///
				if asset.match pattern
					newData = @rfs asset
					# when found, we jump off the loop
					break

			# File maybe doesn't exist
			unless newData?
				# We then assign back the untouched <svga> tag
				newData = originalString
				@logs.errors.missingFiles.push filename

			# File exists
			else
				# We first remove any existing <xml> tag
				xmlTagPattern = /<(?:\?)?xml[^>]+>/i
				newData = newData.replace xmlTagPattern, ''
				# Then remove any existing comments tag
				commentsTagPattern = /<!--[^>]+>/gi
				newData = newData.replace commentsTagPattern, ''
				# we look for the main <svg> tag
				# and extract its possible properties
				svgTagPattern = /<svg([^>]+)>/i
				tags = 0
				newData = newData.replace svgTagPattern, ($0, originalProperties) =>
					# We then create a new svg tag with original properties
					# and append possible <svga> properties
					newString = "<svg #{ originalProperties } #{ properties } >"
					tags++
					@logs.process.tags++
					return newString

				if tags > 0 then @logs.process.filesLength++
				return newData

			# Finaly we can return the new string
			newData

		# Now we can write the file with its new content
		fs.writeFile path, res

options =
	directory: './templates'
	logLevels: 'truc'
	assetsExt: 'bidule'
	templatesExt: ''
app = new SvgAssets options
app.process()