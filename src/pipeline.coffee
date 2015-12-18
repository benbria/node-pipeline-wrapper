stream = require 'stream'

# Given an array of streams, returns a new stream where anything written will be sent to the first stream, and anything
# read will come from the last stream.  All streams will be piped to each other, in order.
class Pipeline extends stream.Duplex
    constructor: (streams, options) ->
        super options
        @done = false

        @input = streams[0]
        @output = streams.reduce (s1, s2) -> s1.pipe s2

        @on 'finish', => @input.end()

        @output.pause()
        @output.on 'error', (err) => @emit 'error', err
        @output.on 'end', => @push null
        @output.on 'data', (chunk) => if !@push(chunk) then @output.pause()

    _read: (size) ->
        @output.resume()

    _write: (chunk, encoding, callback) ->
        @input.write(chunk, encoding, callback)

module.exports = Pipeline
