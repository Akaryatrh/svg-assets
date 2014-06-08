fs = require 'fs'
OptionsManager = require './options-manager'
shared = require './shared-objects'
Logger = require './logger'

module.exports = class SvgAssets


	constructor: (_options) ->

		#console.log shorthand
		@cl = console.log
		@_optionsManager = new OptionsManager _options
		@_logger = new Logger

		return


	process: ->

		if @_optionsManager.init()

			allFiles = @walk shared.options.directory, shared.options.templatesExt
			assetsFiles = @walk shared.options.assets, shared.options.assetsExt
			for file in allFiles
				@findAndReplace file, assetsFiles

		@_logger.log()


	# ReadFileSync
	rfs: (path) ->
		try
			response = fs.readFileSync path, 'UTF-8'

		catch err
			# Catch file not found error
			if err.code isnt 'ENOENT'
				shared.logs.errors.globalMessages.push err
			else
				response = null

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
				shared.logs.errors.missingFiles.push filename

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
				newData = newData.replace svgTagPattern, ($0, originalProperties) ->
					# We then create a new svg tag with original properties
					# and append possible <svga> properties
					newString = "<svg#{ originalProperties }#{ properties }>"
					tags++
					shared.logs.process.tags++
					return newString

				if tags > 0 then shared.logs.process.filesLength++
				return newData

			# Finaly we can return the new string
			newData


		# Now we can write the file with its new content
		if dataTemplate isnt res
			fs.writeFileSync path, res

		res