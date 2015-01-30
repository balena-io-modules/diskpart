fsPlus = require('fs-plus')
childProcess = require('child_process')
sinon = require('sinon')
path = require('path')
chai = require('chai')
expect = chai.expect

helpers = require('../lib/helpers')

describe 'Helpers:', ->

	describe '.getTempScriptPath()', ->

		it 'should return an absolute path', ->
			result = helpers.getTempScriptPath()
			expect(fsPlus.isAbsolute(result)).to.be.true

		# Happens when temporal directory couldn't be constructed
		it 'should not throw an error', ->
			expect(helpers.getTempScriptPath).to.not.throw(Error)

	describe '.execute()', ->

		describe 'if command succeeds', ->

			beforeEach ->
				@childProcessExecStub = sinon.stub(childProcess, 'exec')
				@childProcessExecStub.yields(null, 'Hello World', undefined)

			afterEach ->
				@childProcessExecStub.restore()

			it 'should return the output to the callback', (done) ->
				helpers.execute 'command', (error, output) ->
					expect(error).to.not.exist
					expect(output).to.equal('Hello World')
					done()

		describe 'if command does not succeed', ->

			beforeEach ->
				@childProcessExecStub = sinon.stub(childProcess, 'exec')
				@childProcessExecStub.yields(null, undefined, 'Foo Error')

			afterEach ->
				@childProcessExecStub.restore()

			it 'should return stderr to the callback as an error', (done) ->
				helpers.execute 'command', (error, output) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('Foo Error')
					expect(output).to.not.exist
					done()

		describe 'if there was an error when attempting to execute the command', ->

			beforeEach ->
				@childProcessExecStub = sinon.stub(childProcess, 'exec')
				@childProcessExecStub.yields(new Error('Foo Error'))

			afterEach ->
				@childProcessExecStub.restore()

			it 'should return the error to the callback', (done) ->
				helpers.execute 'command', (error, output) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('Foo Error')
					expect(output).to.not.exist
					done()
