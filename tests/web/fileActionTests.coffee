# Use bolideClient and fakeProject

randomId = () ->
  return Math.floor( Math.random() * 1000000 + 1)

if Meteor.isClient
  Meteor.startup ->
    assert = chai.assert

    #callback: (projectId) ->
    createFakeProject = (files, callback) ->
      Meteor.call 'createFakeProject', files, (error, result) ->
        assert.isUndefined error
        console.log "created project:", result
        Meteor.flush()
        callback result

    #callback: (projectId) ->
    connectDementor = (projectId, callback) ->
      Meteor.http.post "http://localhost:4999/socket/#{projectId}", (error, response) ->
        console.log "Returning from opening socket."
        console.error "open socket:", error.message if error
        assert.isNull error, "Unexpected error:", error
        console.log "Got response from POST socket."
        callback response

    disconnectDementor = (projectId, callback) ->
      Meteor.http.del "http://localhost:4999/socket/#{projectId}", (error, response) ->
        console.log "Got response from DELETE socket with error:", error
        callback()


    #callback: ->
    addDementorFile = (file, callback) ->
      Meteor.http.post "http://localhost:4999/file/#{file._id}", {
        data: {file: file}
        headers: {'Content-Type':'application/json'}
      }, (error, response) ->
        assert.isNull error
        console.log "Got response from POST file."
        callback()

    #callback: (fileContents) ->
    getDementorFile = (fileId, callback) ->
      Meteor.http.get "http://localhost:4999/file/#{fileId}", {
        headers: {'Content-Type':'application/json'}
      }, (error, response) ->
        assert.isNull error
        assert.ok response.data
        console.log "Got response from GET file:", response.data
        callback(response.data)

    describe "File Actions", ->
      projectId = null
      Meteor.subscribe "fakeProject"
      Meteor.autosubscribe ->
        Meteor.subscribe "files", Projects.findOne()?._id

      describe "on request file", ->
        editorState = null
        editorId = "editor" + randomId()

        file = null
        fileData =
          path : 'foo/test.txt'
          isDir : false
          contents : 'A happy duck is a warm duck.'
          aceMode: ->

        Meteor.autorun ->
          file = Files.findOne path: fileData.path

        before (done) ->
          appendEditor editorId
          editorState = new EditorState editorId

          createFakeProject [fileData], (result) ->
            projectId = result
            connectDementor projectId, (response) ->
              addDementorFile file, ->
                done()

        after (done) ->
          disconnectDementor projectId, done

        it 'should set editor body to contents', (done) ->
          editorState.loadFile file, (err) ->
            assert.isNull err
            assert.equal ace.edit(editorId).getValue(), fileData.contents
            done()

      describe 'on save file', ->
        editorState = null
        editorId = "editor" + randomId()

        file = null
        fileData =
          path : 'foo/save.txt'
          isDir : false
          contents : 'A happy duck is a warm duck.'
          aceMode: ->

        newContents = "Run for the hills, little ducky."
        Meteor.autorun ->
          file = Files.findOne path: fileData.path

        before (done) ->
          appendEditor editorId
          editorState = new EditorState editorId

          createFakeProject [fileData], (result) ->
            projectId = result
            connectDementor projectId, (response) ->
              addDementorFile file, ->
                editorState.loadFile file, (err) ->
                  assert.isNull err
                  editorState.getEditor().setValue newContents
                  editorState.save done

        after (done) ->
          disconnectDementor projectId, done

        it "should replace the local file's content", (done) ->
          getDementorFile file._id, (data) ->
            assert.equal data.contents, newContents
            done()
          
        it "should mark the file as unmodified", ->
          file = Files.findOne path: fileData.path
          assert.isFalse file.modified

  ###
      describe 'on revert file', ->
        it "should replace the editor's content with the file's content"
        it "should mark the file as unmodified"

      describe 'on discard file', ->
        it "should remove the file from the fileTree"
        it "should clear the editor"

  ###

