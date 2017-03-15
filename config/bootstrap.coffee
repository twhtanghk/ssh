['ROOTURL', 'ALLOW', 'DENY'].map (name) ->
  if not (name of process.env)
    throw new Error "process.env.#{name} not yet defined"

module.exports =
  bootstrap: (done) ->
    sails.io
      .of require('url').parse(process.env.ROOTURL).pathname
      .on 'connection', (socket) ->
        socket
          .on 'ssh', (opts) ->
            reject = (err) ->
              socket.emit 'data', "#{err.toString()}\r\n"
            SSHClient = require('ssh2').Client
            sshConn = new SSHClient()
            sshConn
              .on 'ready', ->
                socket.emit 'data', 'ssh ready'
                sshConn.shell (err, stream) ->
                  if err
                    return reject err
                  socket.on 'data', (data) ->
                    stream.write data
                  stream
                    .on 'data', (data) ->
                      socket.emit 'data', data.toString 'binary'
                    .on 'close', ->
                      sshConn.end()
                      socket.disconnect true
              .on 'close', ->
                reject 'ssh closed'
              .on 'error', (err) ->
                reject err
              .connect opts
    done()
