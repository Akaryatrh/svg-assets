'use strict'

module.exports = class SharedObjects

		logs: ->
			errors:
				missingFiles: []
				globalMessages: []
			warnings: []
			infos: []
			process:
				tags: 0
				filesLength: 0
			startDate: Date.now()

		defaultOptions: ->
			retObject = {}
			for option, value of @optionsDefinitions
				if value.defaultValue isnt null then retObject[option] = value.defaultValue
			retObject

		optionsDefinitions:
			directory:
				defaultValue: '.'
				commands: '-d, --directory [path]'
				commandDescription: 'Set templates directory source (String)'
			templatesExt:
				defaultValue: ['html', 'htm', 'hbs', 'handlebars']
				commands: '-t, --templates-ext [list]'
				commandDescription: 'Set templates authorized extensions (Array or String)'
			outputDirectory:
				defaultValue: null
				commands: '-o, --output-directory [path]'
				commandDescription: 'Set templates directory destination (String)'
			assets:
				defaultValue: '.'
				commands: '-a, --assets [path]'
				commandDescription: 'Set assets directory source (String)'
			assetsExt:
				defaultValue: ['svg']
				commands: '-A, --assets-ext [list]'
				commandDescription: 'Set assets authorized extensions (Array or String)'
			logLevels:
				defaultValue: ['warning', 'error', 'info']
				commands: '-l, --log-levels [list]'
				commandDescription: 'Set level of logs (Array or String)'
			preserveRoot:
				defaultValue: true
				commands: '-p, --preserve-root'
				commandDescription: 'Set root directories protection (Boolean)'