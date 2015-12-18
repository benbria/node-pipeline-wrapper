stream = require 'stream'
util   = require 'util'

{expect} = require 'chai'
PipelineWrapper = require '../src/pipeline'

describe 'pipline', ->
    it 'should work in object mode', (done) ->
        x = stream.Transform({objectMode: true})
        x._transform = (chunk, encoding, cb) -> cb null, "x: #{chunk}"

        y = stream.Transform({objectMode: true})
        y._transform = (chunk, encoding, cb) -> cb null, "y: #{chunk}"

        pipeline = new PipelineWrapper [x,y], {objectMode: true}
        pipeline.write "hello"
        pipeline.end "bar"

        data = []
        pipeline.on 'data', (d) -> data.push d
        pipeline.on 'end', ->
            try
                expect(data).to.eql ["y: x: hello", "y: x: bar"]
            catch err
                return done err
            done()

    it 'should work in stream mode', (done) ->
        x = stream.Transform()
        x._transform = (chunk, encoding, cb) ->
            chunk = chunk.toString('utf-8')
            chunk = chunk.replace /x/, 'a'
            cb null, new Buffer(chunk)

        y = stream.Transform()
        y._transform = (chunk, encoding, cb) ->
            chunk = chunk.toString('utf-8')
            chunk = chunk.replace /y/, 'b'
            cb null, new Buffer(chunk)

        pipeline = new PipelineWrapper [x,y]
        pipeline.write "xy"
        pipeline.end "yx"

        data = ""
        pipeline.on 'data', (d) -> data = data + d.toString('utf-8')
        pipeline.on 'end', ->
            try
                expect(data).to.eql "abba"
            catch err
                return done err
            done()
