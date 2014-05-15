fs = require 'fs'

rfdr = (dir, callback) ->
  results = []
  fs.readdir dir, (err, list) ->
    if (err) then return callback err
    pending = list.length
    if !pending then return callback null, results

    for file in list
      file = dir + '/' + file
      fs.stat file, (err, stat) ->
        if stat and stat.isDirectory()
          rfdr file, (err, res) ->
            results = results.concat res
            if !--pending then callback null, results

        else
          results.push file
          if !--pending then callback null, results



# ReadFile
rf = (path, callback) ->
	fs.readFile './'+path, 'UTF-8', (err, data) ->
		if err
			throw err
			return

		callback data
		return

# ReadFileSync
rfs = (path) ->
	try
		response = fs.readFileSync './'+path, 'UTF-8'
	catch err
		# Catch file not found error
		if err.code isnt 'ENOENT'
			throw e
		else
			response = null;

	response


findAndReplace = (path) ->
	rf path, (dataTemplate) ->
		# We look for the tag <svga> in template
		# and will extract the filename and possible properties
		pattern = /(<svga(.*)>(.+)<\/svga>)/gi
		res = dataTemplate.replace pattern, ($0, originalString, properties, filename) ->
			# We want to replace <svga> tag with contents from matching svg file
			newData = rfs 'assets/' + filename + '.svg'

			# File maybe doesn't exist
			if newData is null
				# We then assign back the untouched <svga> tag
				newData = originalString
				console.error 'Error: ' + filename + '.svg not found or not readable'

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
				newData = newData.replace svgTagPattern, ($0, originalProperties) ->
					# We then create a new svg tag with original properties
					# and append possible <svga> properties
					newString = '<svg' + originalProperties + properties + '>'
					return newString;

			# Finaly we can return the new string
			newData;

		# Now we can write the (new or existing) file with its new content
		fs.writeFile 'test.html', res
		return


rfdr 'templates', (err, results) ->
	if err then throw err
	console.log results