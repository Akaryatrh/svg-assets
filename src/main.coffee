'use strict'

fs = require 'fs'
mkdirp = require 'mkdirp'
OptionsManager = require './options-manager'
Logger = require './logger'
sharedObjects = require './shared-objects'

module.exports = class SvgAssets


	constructor: (@options) ->

		@cl = console.log
		@_optionsManager = new OptionsManager
		@_logger = new Logger

		# shared instance is only used for unit testing
		@shared = new sharedObjects
		@shared.logs = @shared.logs()

		return


	process: ->
		initOptions = @_optionsManager.init(@options)
		@shared = initOptions.shared

		if initOptions.success
			allFiles = @walk @shared.options.directory, @shared.options.templatesExt
			assetsFiles = @walk @shared.options.assets, @shared.options.assetsExt

			for file in allFiles
				@findAndReplace file, assetsFiles
		@_logger.log(@shared)


	# ReadFileDirSync
	rfds: (path, type) ->
		try
			switch type
				when 'file'
				then response = fs.readFileSync path, 'UTF-8'

				when 'folder'
				then response = fs.readdirSync path

		catch err
			error = "Error: #{ err.message }"
			@shared.logs.errors.globalMessages.push error
			return null

		response

	checkIfDir: (path) ->
		try
			fs.lstatSync path
			fs.statSync(path).isDirectory()
		catch err
			error = "Error: #{ err.message }"
			@shared.logs.errors.globalMessages.push error
			return null
			
		


	# List files recursively
	walk: (dir, ext)->

		files = []
		matcher = (fn) -> fn.match /// \.(#{ ext.join('|') }) ///

		_walk = (dir) =>
			unless @checkIfDir dir then return files

			fns = @rfds dir, 'folder'
			for fn in fns
				fn = dir + '/' + fn
				if matcher fn then files.push fn
				if fs.statSync(fn).isDirectory() then _walk fn
			return files

		_walk dir


	#Find and replace <svga>
	findAndReplace: (path, assetsFiles) ->

		dataTemplate = @rfds path, 'file'

		# We look for the tag <svga> in template
		# and will extract the filename and possible properties
		pattern = /(<svga(.*)>(.+)<\/svga>)/gi
		res = dataTemplate.replace pattern, ($0, originalString, properties, filename) =>
			# We want to replace <svga> tag with contents from matching svg file
			for asset in assetsFiles
				# we look for an asset with a path ending with filename
				pattern = ///\/#{filename}\.svg$///
				if asset.match pattern
					newData = @rfds asset, 'file'
					# when found, we jump off the loop
					break

			# File maybe doesn't exist
			unless newData?
				# We then assign back the untouched <svga> tag
				newData = originalString
				@shared.logs.errors.missingFiles.push filename

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
					newString = "<svg#{ originalProperties }#{ properties }>"
					tags++
					@shared.logs.process.tags++
					return newString

				if tags > 0 then @shared.logs.process.filesLength++
				return newData

			# Finaly we can return the new string
			newData

		# Check output options, then change path if needed
		outputDir = @shared.options.outputDirectory
		currentDir = @shared.options.directory
		extensions = @shared.options.templatesExt.join('|')
		pattern =///
			#{ currentDir} # current_directory
			(.*\/{1})? # /folder1/folder2/
			(?:.+\.( #{ extensions } )){1}$ # filename.ext
			///i

		finalPath = finalDir = ''
		if outputDir?
			# Extract path without filename and replace root directory
			finalDir = path.replace pattern, outputDir + '/$1'
			# Replace root directory
			finalPath = path.replace currentDir, outputDir + '/'
			# Sanitize slashes
			finalPath = finalPath.replace "//", "/"
			finalDir = finalDir.replace "//", "/"
		else
			finalPath = path
			finalDir = currentDir

		# Now we can write the file with its new content
		if dataTemplate isnt res
			# Use mkdirp that create path if not exists
			mkdirp finalDir, (err) =>
				if (err)
					@shared.logs.errors.globalMessages.push err
				else
					fs.writeFileSync finalPath, res

		res