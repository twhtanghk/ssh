cfg = require './config.json'
if not ('ROOTURL' of cfg)
  throw new Error "cfg.#{ROOTURL} not defined yet"

io = require 'socket.io-client'
socket = null
term = null

window.connect = ->
  [host, port] = document.getElementById('server').value.split ':'
  try 
    port = parseInt port
  catch e
    alert e.toString()
  socket.emit 'ssh',
    host: host
    port: port
    username: document.getElementById('username').value
    password: document.getElementById('password').value 

window.addEventListener 'load', ->
  elem = document.getElementById 'terminal-container'
  Terminal = require 'xterm'
  term = new Terminal cursorBlink: true
  term.open elem

  opts = path: "#{require('url').parse(cfg.ROOTURL).pathname}/socket.io"
  socket = io cfg.ROOTURL, opts
    .on 'error', console.log
    .on 'connect', ->
      term.on 'data', (data) ->
        socket.emit 'data', data
    .on 'data', (data) ->
      term.write data
    .on 'disconnect', ->
      term.write "Disconnected\r\n"
