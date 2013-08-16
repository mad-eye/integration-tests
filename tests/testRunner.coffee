spawn = require('child_process').spawn
util = require "util"

dementor = null
startDementor = (clean, callback)->
  #TODO should be resetting this directory
  if clean
    args = ["--clean"]
    console.log "Starting clean dementor."
  else
    args = null
  dementor = spawn "../../dementor/bin/madeye.js", args, {cwd: "tests/fake-project"}
  regex = /https?:\/\/[\w.:]+\/edit\/[-\w]+/
  goneOnce = false
  dementor.stdout.on "data", (data)->
    data = data.toString()
    util.print "DEMENTOR STDOUT: #{data}"
    return if goneOnce
    if match = regex.exec(data)
      callback match[0]
      goneOnce = true
    #else
      #console.log "NO MATCH"
  dementor.stderr.on "data", (data)->
    util.print "DEMENTOR STDERR: #{data}"
  dementor.on "exit", (code)->
    if code !=0
      console.error "dementor exited with non-zero status code"
      process.exit(1)
    # console.log "Dementor exited with status #{code}"

runCasper = (projectUrl, tests, callback) ->
  #console.log "SPAWNING CASPER PROCESS"
  process.env.PROJECT_URL = projectUrl
  casperJs = spawn "casperjs", ["--ignore-ssl-errors=yes", "test"].concat tests
  #console.log "CASPER SPAWNED"
  casperJs.stdout.on "data", (data)->
    console.log "CASPERJS STDOUT #{data}"
  casperJs.stderr.on "data", (data)->
    console.log "CASPERJS STDERR #{data}"
  casperJs.on "exit", (code)->
    console.log "casper exited with exit code #{code}"
    dementor.kill()
    callback code


#after starting dementor run casperjs against the madeye server
startDementor true, (projectUrl) ->
  runCasper projectUrl, ["tests/happyPathTest.coffee"], (code) ->
    return process.exit(code) if code
    startDementor false, (projectUrl) ->
      #console.log "STARTING CASPER"
      runCasper projectUrl, ["tests/happyPathTest.coffee"], (code) ->
        process.exit(code)
