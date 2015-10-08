mockFs = require('mock-fs')
sinon = require('sinon')
_ = require('lodash')
fs = require('fs')
fsPlus = require('fs-plus')
chai = require('chai')
chai.use(require('sinon-chai'))
expect = chai.expect

diskpart = require('../lib/diskpart')
helpers = require('../lib/helpers')

describe 'Diskpart:', ->

	describe '.runScript()', ->

		describe 'if not script option was passed', ->

			it 'should throw an error', ->
				expect ->
					diskpart.runScript(null, _.noop)
				.to.throw('Missing diskpart script path')

		describe 'if script exists', ->

			beforeEach ->
				@fsExistsStub = sinon.stub(fs, 'exists')
				@fsExistsStub.yields(true)

				@fsPlusIsFileStub = sinon.stub(fsPlus, 'isFileSync')
				@fsPlusIsFileStub.returns(true)

				@helpersExecuteStub = sinon.stub(helpers, 'execute')
				@helpersExecuteStub.yields(null, 'Hello World')

			afterEach ->
				@fsExistsStub.restore()
				@fsPlusIsFileStub.restore()
				@helpersExecuteStub.restore()

			it 'should call helpers.execute with the correct arguments', (done) ->
				@timeout(5000)
				diskpart.runScript 'myScript', (error, output) =>
					expect(error).to.not.exist
					expect(output).to.equal('Hello World')

					expect(@helpersExecuteStub).to.have.been.calledOnce
					expectedCommand = 'diskpart /s "myScript"'
					expect(@helpersExecuteStub).to.have.been.calledWith(expectedCommand)
					done()

		describe 'if script does not exist', ->

			beforeEach ->
				@fsExistsStub = sinon.stub(fs, 'exists')
				@fsExistsStub.yields(false)

			afterEach ->
				@fsExistsStub.restore()

			it 'should return an error', (done) ->
				diskpart.runScript 'unexistant script', (error, output) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('Diskpart script does not exist: unexistant script')
					expect(output).to.not.exist
					done()

		describe 'if script is not a file', ->

			beforeEach ->
				@fsExistsStub = sinon.stub(fs, 'exists')
				@fsExistsStub.yields(true)

				@fsPlusIsFileStub = sinon.stub(fsPlus, 'isFileSync')
				@fsPlusIsFileStub.returns(false)

			afterEach ->
				@fsExistsStub.restore()
				@fsPlusIsFileStub.restore()

			it 'should return an error', (done) ->
				diskpart.runScript 'invalid script', (error, output) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('Diskpart script is not a file: invalid script')
					expect(output).to.not.exist
					done()

	describe '.evaluate()', ->

		describe 'given no input', ->

			it 'should throw an error', ->
				expect ->
					diskpart.evaluate()
				.to.throw('Diskpart missing input')

		describe 'given invalid input', ->

			it 'should throw an error', ->
				expect ->
					diskpart.evaluate('Hello World')
				.to.throw('Diskpart input should be an array of commands')

		describe 'given valid input', ->

			beforeEach ->
				mockFs({})

				@helpersExecuteStub = sinon.stub(helpers, 'execute')
				@helpersExecuteStub.yields(null, 'Hello World')

			afterEach ->
				mockFs.restore()

				@helpersExecuteStub.restore()

			# TODO: We should test that helpers.execute was called with
			# a generated file script living under temp.
			# TODO: We should test that the files were unlinked
			# after execution.

			it 'should call helpers.execute', (done) ->
				@timeout(5000)
				diskpart.evaluate [ 'rescan' ], (error, output) =>
					expect(error).to.not.exist
					expect(output).to.equal('Hello World')
					expect(@helpersExecuteStub).to.have.been.calledOnce
					done()
