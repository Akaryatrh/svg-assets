module.exports = class SharedObjects

		logs : ->
			errors:
				missingFiles: []
				globalMessages: []
			warnings: []
			infos: []
			process:
				tags: 0
				filesLength: 0
			startDate: Date.now()

		defaultOptions : ->
			templatesExt: ['html', 'htm', 'hbs', 'handlebars']
			assetsExt: ['svg']
			logLevels: ['warning', 'error', 'info']
			#deactivated for now matchTags: ['svga']
			preserveRoot: true