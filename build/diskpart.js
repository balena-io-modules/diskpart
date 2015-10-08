var async, fs, fsPlus, helpers, _;

_ = require('lodash');

fs = require('fs');

fsPlus = require('fs-plus');

async = require('async');

helpers = require('./helpers');

exports.runScript = function(scriptPath, callback) {
  if (scriptPath == null) {
    throw new Error('Missing diskpart script path');
  }
  return async.waterfall([
    function(callback) {
      return fs.exists(scriptPath, function(exists) {
        var error;
        if (!exists) {
          error = new Error("Diskpart script does not exist: " + scriptPath);
          return callback(error);
        }
        return callback();
      });
    }, function(callback) {
      var error, isFile;
      isFile = fsPlus.isFileSync(scriptPath);
      if (!isFile) {
        error = new Error("Diskpart script is not a file: " + scriptPath);
        return callback(error);
      }
      return callback();
    }, function(callback) {
      return helpers.execute("diskpart /s \"" + scriptPath + "\"", callback);
    }, function(output, callback) {
      return setTimeout(function() {
        return callback(null, output);
      }, 2000);
    }
  ], callback);
};

exports.evaluate = function(input, callback) {
  var scriptFilePath;
  if (input == null) {
    throw new Error('Diskpart missing input');
  }
  if (!_.isArray(input)) {
    throw new Error('Diskpart input should be an array of commands');
  }
  scriptFilePath = helpers.getTempScriptPath();
  return async.waterfall([
    function(callback) {
      return fs.writeFile(scriptFilePath, input.join('\n'), callback);
    }, function(callback) {
      return exports.runScript(scriptFilePath, callback);
    }, function(output, callback) {
      return fs.unlink(scriptFilePath, function(error) {
        if (error != null) {
          return callback(error);
        }
        return callback(null, output);
      });
    }
  ], callback);
};
