['ALLOW', 'DENY'].map (name) ->
  if not (name of process.env)
    throw new Error "process.env.#{name} not yet defined"

ip = require 'ip'
Promise = require 'bluebird'
dns = Promise.promisifyAll require 'dns'

allow = (host) ->
  dns
    .lookupAsync host
    .then (addr) ->
      ALLOW = ip.cidrSubnet process.env.ALLOW
      DENY = ip.cidrSubnet process.env.DENY
      ALLOW.contains(addr) and not DENY.contains(addr)
    .then (allowed) ->
      if not allowed
        Promise.reject new Error "#{host} not allowed with #{process.env.ALLOW} and #{process.env.DENY}"

module.exports =
  bootstrap: (done) ->
    sails.io
      .on 'connection', (socket) ->
        socket
          .on 'ssh', (opts) ->
            reject = (err) ->
              socket.emit 'data', "#{err.toString()}\r\n"
              socket.disconnect true
            resolve = ->
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
            allow opts.host
              .then resolve, reject
    done()
