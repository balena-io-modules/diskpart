diskpart
---------

[![npm version](https://badge.fury.io/js/diskpart.svg)](http://badge.fury.io/js/diskpart)
[![dependencies](https://david-dm.org/resin-io/diskpart.png)](https://david-dm.org/resin-io/diskpart.png)
[![Build status](https://ci.appveyor.com/api/projects/status/4l3wln4g967n9hoc?svg=true)](https://ci.appveyor.com/project/jviotti/diskpart)

Run Windows diskpart scripts in NodeJS.

Notice this module **requires** running with admin privileges. Use modules such as [windosu](https://www.npmjs.com/package/windosu) to provide elevation if you require that feature.

Example:

```coffee
var diskpart = require('diskpart');

diskpart.evaluate([ 'rescan' ], function(error, output) {
		if (error) throw error;
		console.log(output);
});
```
***
```
Microsoft DiskPart version 6.3.9600

Copyright (C) 1999-2013 Microsoft Corporation.
On computer: DELL

Please wait while DiskPart scans your configuration...

DiskPart has finished scanning your configuration.
```

Installation
------------

Install `diskpart` by running:

```sh
$ npm install --save diskpart
```

Documentation
-------------

### diskpart.runScript(String scriptPath, Function callback)

Run a diskpart script file.

#### scriptPath

The path to the script.

#### callback(error, output)

- `error` is a possible error.
- `output` a string containing the output of the command.

Notice that if the command outputs to `stderr`, it will be returned wrapped in an `Error` instance.

Example:

```coffee
var diskpart = require('diskpart');

diskpart.runScript('C:\\myDiskpartScript', function(error, output) {
		if (error) throw error;
		console.log(output);
});
```

### diskpart.evaluate(String[] input, Function callback)

Execute a series of diskpart commands.

#### input

An array of strings containing diskpart commands.

#### callback(error, output)

- `error` is a possible error.
- `output` a string containing the output of the command.

Notice that if the command outputs to `stderr`, it will be returned wrapped in an `Error` instance.

Example:

```coffee
var diskpart = require('diskpart');

diskpart.evaluate([ 'rescan', 'list disk' ], function(error, output) {
		if (error) throw error;
		console.log(output);
});
```

Tests
-----

Run the test suite by doing:

```sh
$ gulp test
```

Contribute
----------

- Issue Tracker: [github.com/resin-io/diskpart/issues](https://github.com/resin-io/diskpart/issues)
- Source Code: [github.com/resin-io/diskpart](https://github.com/resin-io/diskpart)

Before submitting a PR, please make sure that you include tests, and that [coffeelint](http://www.coffeelint.org/) runs without any warning:

```sh
$ gulp lint
```

Support
-------

If you're having any problem, please [raise an issue](https://github.com/resin-io/diskpart/issues/new) on GitHub.

License
-------

The project is licensed under the MIT license.
