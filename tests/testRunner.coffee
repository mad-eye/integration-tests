spawn = require('child_process').spawn
util = require "util"

dementor = null
startDementor = (callback)->
  #TODO should be resetting this directory
  dementor = spawn "../../dementor/bin/madeye", null, {cwd: "tests/fake-project"}
  dementor.stdout.on "data", (data)->
    if match = /http[-\w\d\/:\.]*/.exec(data)
      callback match[0]
    util.print "DEMENTOR STDOUT: #{data}"
  dementor.stderr.on "data", (data)->
    util.print "DEMENTOR STDERR: #{data}"
  dementor.on "exit", (code)->
    console.log "Dementor exited with status #{code}"

#after starting dementor run casperjs against the madeye server
startDementor (projectUrl)->
  console.log "testing project at #{projectUrl}"
  casperJs = spawn "casperjs", ["tests/happyPathTest.coffee", projectUrl]
  casperJs.stdout.on "data", (data)->
    console.log "CASPERJS STDOUT #{data}"
  casperJs.stderr.on "data", (data)->
    console.log "CASPERJS STDERR #{data}"
  casperJs.on "exit", (code)->
    console.log "casper exited with status #{code}"
    dementor.kill()
