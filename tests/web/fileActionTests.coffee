# Use bolideClient and fakeProject

randomId = () ->
  return Math.floor( Math.random() * 1000000 + 1)

Meteor.startup ->
  describe "File Actions", ->
    assert = chai.assert
    projectId = null
    Meteor.subscribe "fakeProject"
    Meteor.autosubscribe ->
      projectId = Projects.findOne()?._id
      Meteor.subscribe "files", projectId

    file = null
    filePath = 'foo/test.txt'
    fileData =
      path : filePath
      isDir : false
      contents : 'A happy duck is a warm duck.'
      aceMode: ->

    Meteor.autorun ->
      file = Files.findOne path: filePath

    describe "on request file", ->
      editorState = null
      editorId = "editor" + randomId()

      before (done) ->
        appendEditor editorId
        editorState = new EditorState editorId

        Meteor.call 'createFakeProject', [fileData], (error, result) ->
          assert.isUndefined error
          projectId = result
          console.log "created project:", projectId
          Meteor.flush()
          

          Meteor.http.post "http://localhost:4999/socket/#{projectId}", (error, response) ->
            console.log "Returning from opening socket."
            console.error "open socket:", error.message if error
            assert.isNull error, "Unexpected error:", error
            console.log "Got response from POST socket."

            Meteor.http.post "http://localhost:4999/file/#{file._id}", {
              data: {file: file}
              headers: {'Content-Type':'application/json'}
            }, (error, response) ->
              assert.isNull error
              console.log "Got response from POST file."
              done()

      after (done) ->
        Meteor.http.del "http://localhost:4999/socket/#{projectId}", (error, response) ->
          console.log "Got response from DELETE socket with error:", error
          done()

      it 'should set editor body to contents', (done) ->
        editorState.loadFile file, (err) ->
          assert.isNull err
          assert.equal ace.edit(editorId).getValue(), fileData.contents
          done()

###
    describe 'on save file', ->
      it "should replace the local file's content"
      it "should mark the file as unmodified"

    describe 'on revert file', ->
      it "should replace the editor's content with the file's content"
      it "should mark the file as unmodified"

    describe 'on discard file', ->
      it "should remove the file from the fileTree"
      it "should clear the editor"

###

