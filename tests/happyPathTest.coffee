casper = require("casper").create
  verbose: true
  logLevel: "debug"
  onError: (error)->
    console.error "ERROR IS #{error}"    

url = casper.cli.args[0]

console.log "opening url #{url}"
casper.start url, ->
  @wait 1000, ->
    @test.assertExists "#projectName"
    @test.assertTitle "MadEye"
    result = @capture("screenshot.png")
    console.log "page rendered"

casper.run ->
  console.log "tests complete"
  @exit 0