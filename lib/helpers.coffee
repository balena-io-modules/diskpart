_ = require('lodash')
path = require('path')
childProcess = require('child_process')

exports.getTempScriptPath = ->
	currentTime = new Date().getTime()
	tempDirectory = process.env.TEMP or process.env.TMPDIR
	return path.join(tempDirectory, "_diskpart-#{currentTime}")

exports.execute = (command, callback) ->
	childProcess.exec command, {}, (error, stdout, stderr) ->
		return callback(error) if error?
		return callback(new Error(stderr)) if not _.isEmpty(stderr)
		return callback(null, stdout)
