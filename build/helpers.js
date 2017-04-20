var childProcess, debug, path, _;

_ = require('lodash');

path = require('path');

childProcess = require('child_process');

debug = require('debug')(require('../package.json').name);

debug.log = console.log.bind(console);

exports.getTempScriptPath = function() {
  var currentTime, tempDirectory;
  currentTime = new Date().getTime();
  tempDirectory = process.env.TEMP || process.env.TMPDIR;
  return path.join(tempDirectory, "_diskpart-" + currentTime);
};

exports.execute = function(command, callback) {
  return childProcess.exec(command, {}, function(error, stdout, stderr) {
    debug('stderr: %s', stderr);
    debug('stdout: %s', stdout);
    if (error != null) {
      return callback(error);
    }
    if (!_.isEmpty(stderr)) {
      return callback(new Error(stderr));
    }
    return callback(null, stdout);
  });
};
