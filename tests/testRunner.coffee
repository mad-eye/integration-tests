spawn = require('child_process').spawn
util = require "util"

dementor = null
startDementor = (callback)->
  #TODO should be resetting this directory
  dementor = spawn "../../dementor/bin/madeye.js", null, {cwd: "tests/fake-project"}
  dementor.stdout.on "data", (data)->
    if match = not /hangout/.exec(data) and  /http[-\w\d\/:\.]*/.exec(data)
      callback match[0]
    util.print "DEMENTOR STDOUT: #{data}"
  dementor.stderr.on "data", (data)->
    util.print "DEMENTOR STDERR: #{data}"
  dementor.on "exit", (code)->
    if code !=0
      console.error "dementor exited with non-zero status code"
      process.exit(1)
    # console.log "Dementor exited with status #{code}"

#after starting dementor run casperjs against the madeye server
startDementor (projectUrl)->
  process.env.PROJECT_URL = projectUrl
  casperJs = spawn "casperjs", ["test", "tests/happyPathTest.coffee"]
  casperJs.stdout.on "data", (data)->
    console.log "CASPERJS STDOUT #{data}"
  casperJs.stderr.on "data", (data)->
    console.log "CASPERJS STDERR #{data}"
  casperJs.on "exit", (code)->
    # console.log "casper exited with #{code}"
    dementor.kill()
    process.exit(code)
