clc = require 'cli-color'
shared = require './shared-objects'

module.exports = class Logger

	constructor: ->
		@cl = console.log

	log: ->

		#Log header
		@cl clc.reset
		@cl " 𝘀𝘃𝗴 𝗮𝘀𝘀𝗲𝘁𝘀 Ξ #{ @dateNow() }"

		# Regular log
		if shared.logs.process.filesLength > 0
			shared.logs.infos.push "#{ shared.logs.process.tags } <svga> tags have been processed in #{shared.logs.process.filesLength} files"
		else
			shared.logs.warnings.push "No file processed :\n
			∷    Processing could have been aborted due to wrong options definitions\n
			∷    No <svga> tags might have not been found\n
			∷    Found <svga> tags might have not any matched files"

		missingFiles = []
		# Assets error log
		for missingFile in shared.logs.errors.missingFiles
			missingFiles.push '"' + missingFile + '.svg"'

		if missingFiles.length
			shared.logs.errors.globalMessages.push "
			#{shared.logs.errors.missingFiles.length} assets file(s) not found or not readable:
			 #{ missingFiles.join(',') }"


		### OUTPUT ###

		# Colors
		errorCl = clc.red
		warnCl = clc.yellow
		infoCl = clc.green
		exeCl = clc.blackBright

		# Warning log
		if shared.options.logLevels.indexOf "warning" > -1
			for warning in shared.logs.warnings
				@cl warnCl(' → Warning: ') + warning

		# Info log
		if shared.options.logLevels.indexOf "info" > -1
			for info in shared.logs.infos
				@cl infoCl(' → Info: ') + info

		# Global error log
		if shared.options.logLevels.indexOf "error" > -1
			for error in shared.logs.errors.globalMessages
				@cl errorCl(' → Error: ') + error

		# Exec time
		process.on "exit", =>
		  end = Date.now()
		  @cl exeCl(" → svgAssets did its job in %dms"), (end - shared.logs.startDate) / 1000

		return

	#Date util
	dateNow: ->
		return new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '') + ' UTC'