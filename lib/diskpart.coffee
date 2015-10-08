_ = require('lodash')
fs = require('fs')
fsPlus = require('fs-plus')
async = require('async')
helpers = require('./helpers')

exports.runScript = (scriptPath, callback) ->

	if not scriptPath?
		throw new Error('Missing diskpart script path')

	async.waterfall([

		(callback) ->
			fs.exists scriptPath, (exists) ->
				if not exists
					error = new Error("Diskpart script does not exist: #{scriptPath}")
					return callback(error)
				return callback()

		(callback) ->

			# TODO: This should be async, however fs-plus doesn't
			# exposes a isFile async function for some reason.
			isFile = fsPlus.isFileSync(scriptPath)

			if not isFile
				error = new Error("Diskpart script is not a file: #{scriptPath}")
				return callback(error)

			return callback()

		(callback) ->
			helpers.execute("diskpart /s \"#{scriptPath}\"", callback)

		(output, callback) ->

			# Windows needs some time after the diskpart script
			# is executed to reflect the changes.
			# This mainly happened in Windows 10.
			# An empirically derivated value that seems to be enough is 2s.
			setTimeout ->
				return callback(null, output)
			, 2000
	], callback)

exports.evaluate = (input, callback) ->

	if not input?
		throw new Error('Diskpart missing input')

	if not _.isArray(input)
		throw new Error('Diskpart input should be an array of commands')

	scriptFilePath = helpers.getTempScriptPath()

	async.waterfall([

		(callback) ->
			fs.writeFile(scriptFilePath, input.join('\n'), callback)

		(callback) ->
			exports.runScript(scriptFilePath, callback)

		(output, callback) ->
			fs.unlink scriptFilePath, (error) ->
				return callback(error) if error?
				return callback(null, output)

	], callback)
