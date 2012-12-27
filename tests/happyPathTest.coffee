# USE THIS SECTION TO BETTER DEBUG ANY BROWSER ISSUES
# Unfortunatley it seems that capser is created in this way
# the test suite never exits

# casper = require("casper").create
#  verbose: true
#  logLevel: "debug"
#  onError: (error)->
#    console.error "ERROR IS #{error}"    

# IMPORTANT 
# Its critical to include assert statments that uniquely identify the assertion
# as casperjs stacktraces all point to line :-/ TODO consider casper alternatives

url = casper.cli.args[1]

console.log "opening url #{url}"

casper.start url, ->
  @wait 5000, ->
    @test.assertExists "#projectName"

    # projectNameHTML = @getHTML "#projectName"
    # projectNameMatches = /fake-project/.test(projectNameHTML)
    # @test.assert projectNameMatches, "project name matches fake-project"

    # fileTreeHTML = @getHTML ".fileTree"
    # file1htmlFound = /file1.html/.test fileTreeHTML
    # file2jsFound = /file2.js/.test fileTreeHTML
    # libFound = /lib/.test fileTreeHTML
    # @test.assert(file1htmlFound, "file1.html found")
    # @test.assert(file2jsFound, "file2.js found")
    # @test.assert(libFound, "lib is found")

    @test.assertTitle "MadEye"
    result = @capture("screenshot.png")

casper.run ->
  @test.done()
