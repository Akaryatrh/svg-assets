'use strict'

clc = require 'cli-color'
Util = require 'util'
sharedObjects = require './shared-objects'

module.exports = class Logger

	constructor: ->
		@cl = console.log
		@shared = new sharedObjects()
		@shared.logs = @shared.logs()


	#Date util
	dateNow: ->
		return new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '') + ' UTC'


	log: (shared) ->

		date = @dateNow()
		#Log header
		logOutput = "𝘀𝘃𝗴 𝗮𝘀𝘀𝗲𝘁𝘀 Ξ #{ date }"
		@shared = shared ? @shared

		# Regular log
		if @shared.logs.process.filesLength > 0
			@shared.logs.infos.push """
			#{ @shared.logs.process.tags } <svga> tag(s) have been processed in #{@shared.logs.process.filesLength} file(s)
			"""
		else
			@shared.logs.warnings.push """
			No file processed :
			\t∷ Processing could have been aborted due to wrong options usage or unexpected error
			\t∷ No <svga> tags could have been found
			\t∷ Found <svga> tags might have not matched any files
			"""

		missingFiles = []
		# Assets error log
		for missingFile in @shared.logs.errors.missingFiles
			missingFiles.push '"' + missingFile + '.svg"'

		if missingFiles.length > 0
			@shared.logs.errors.globalMessages.push """
			#{@shared.logs.errors.missingFiles.length} assets file(s) not found or not readable:
			 #{ missingFiles.join(',') }
			"""


		### OUTPUT ###

		# Warning log
		if @shared.options?.logLevels.indexOf "warning" > -1
			for warning in @shared.logs.warnings
				logOutput += @coloringOutput 'warning', warning

		# Info log
		if @shared.options?.logLevels.indexOf "info" > -1
			for info in @shared.logs.infos
				logOutput += @coloringOutput 'info', info

		# Global error log
		if @shared.options?.logLevels.indexOf "error" > -1
			for error in @shared.logs.errors.globalMessages
				logOutput += @coloringOutput 'error', error

		logOutput += @coloringOutput 'exec'
		@cl logOutput

		finalValues =
			logOutput: logOutput
			logs: @shared.logs

		return finalValues

	coloringOutput: (type, message) ->
		#shorthands to cli-colors
		errorCl = clc.red
		warnCl = clc.yellow
		infoCl = clc.green
		exeCl = clc.blackBright

		# Default values
		message ?= ''
		wording = ''

		switch type
			when "warning"
				method = warnCl
				wording = 'Warning: '
			when 'error'
				method = errorCl
				wording = 'Error: '
			when 'info'
				method = infoCl
				wording = 'Info: '
			when 'exec'
				method = exeCl
				end = (Date.now() - @shared.logs.startDate) / 1000
				wording = "svgAssets did its job in #{ end }ms"

		finalMessage = "\n→ #{ wording }"

		return method(finalMessage) + message

