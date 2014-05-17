fs = require 'fs'

dir = './templates'

class svgAssets
	constructor: (@name) ->
		@logs =
			errors : []
			tags : 0
			filesLength : 0

	process: (dir) ->
		allFiles = @walk dir
		for file in allFiles
			@findAndReplace file

		@log()


	log: ->
		# Regular log
		console.log 'Processing done: '+@logs.tags + ' tags have been processed in ' + @logs.filesLength + ' files'
		filenames = []

		# Errors log
		for filename in @logs.errors
			filenames.push '"' + filename + '.svg"'

		if filenames.length
			console.error 'Error: ' + filenames.join(',') + ' not found or not readable'


	# ReadFile
	rf: (path, callback) ->
		fs.readFile './'+path, 'UTF-8', (err, data) ->
			if err
				throw err
				return

			callback data
			return


	# ReadFileSync
	rfs: (path) ->
		try
			response = fs.readFileSync './'+path, 'UTF-8'
		catch err
			# Catch file not found error
			if err.code isnt 'ENOENT'
				throw e
			else
				response = null;

		response


	# List files recursively
	walk: (dir) ->

		files = []
		matcher = (fn) -> fn.match /\.(html|hbs)/

		_walk = (dir) ->
			unless fs.statSync(dir).isDirectory() then return files

			fns = fs.readdirSync dir
			for fn in fns
				fn = dir + '/' + fn
				if matcher fn then files.push fn
				if fs.statSync(fn).isDirectory() then _walk fn
			return files

		_walk(dir)


	#Find and replace <svga>
	findAndReplace: (path) ->
		dataTemplate = @rfs path
		# We look for the tag <svga> in template
		# and will extract the filename and possible properties
		pattern = /(<svga(.*)>(.+)<\/svga>)/gi
		res = dataTemplate.replace pattern, ($0, originalString, properties, filename) =>
			# We want to replace <svga> tag with contents from matching svg file
			newData = @rfs 'assets/' + filename + '.svg'

			# File maybe doesn't exist
			if newData is null
				# We then assign back the untouched <svga> tag
				newData = originalString
				@logs.errors.push filename

			# File exists
			else
				# we first remove any existing <xml> tag
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
					newString = '<svg' + originalProperties + properties + '>'
					tags++
					@logs.tags++
					return newString

				if tags > 0 then @logs.filesLength++
				return newData

			# Finaly we can return the new string
			newData

		# Now we can write the file with its new content
		fs.writeFile path, res


app = new svgAssets
app.process dir