['ROOTURL', 'ALLOW', 'DENY'].map (name) ->
  if not (name of process.env)
    throw new Error "process.env.#{name} not yet defined"

ip = require 'ip'

allow = (addr) ->
  ALLOW = ip.cidrSubnet process.env.ALLOW
  DENY = ip.cidrSubnet process.env.DENY
  ALLOW.contains(addr) and not DENY.contains(addr)

module.exports =
  bootstrap: (done) ->
    sails.io
      .of require('url').parse(process.env.ROOTURL).pathname
      .on 'connection', (socket) ->
        socket
          .on 'ssh', (opts) ->
            reject = (err) ->
              socket.emit 'data', "#{err.toString()}\r\n"
              socket.disconnect true
            try
              if not allow opts.host
                return reject "#{opts.host} not allowed"
            catch e
              reject e
              return
            sails.log.debug "abc"
            SSHClient = require('ssh2').Client
            sshConn = new SSHClient()
            sshConn
              .on 'ready', ->
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
              .on 'error', (err) ->
                reject err
              .connect opts
    done()
