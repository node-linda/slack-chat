path = require 'path'

config = require path.resolve 'config'
console.log config

Slackbot = require 'slackbot'
slack = new Slackbot config.slack.team, process.env.SLACK_TOKEN

LindaClient = require('linda-socket.io').Client
socket = require('socket.io-client').connect(config.linda.url)
linda = new LindaClient().connect(socket)

ts = linda.tuplespace(config.linda.space)

send = (msg, callback = ->) ->
  slack.send config.slack.channel, msg, callback

linda.io.on 'connect', ->
  console.log "socket.io connect!!"
  send "linda-slack-chat start"

  ts.watch {type: "slack", cmd: "post"}, (err, tuple) ->
    return if tuple.data.response?
    return unless tuple.data.value?
    console.log tuple
    msg = ":feelsgood: 《Linda》 #{tuple.data.value} 《#{ts.name}》"
    send msg, (err, res, body) ->
      if err
        tuple.data.response = "fail"
        ts.write tuple.data
        return
      tuple.data.response = body
      ts.write tuple.data
