# Use bolideClient and fakeProject

randomId = () ->
  return Math.floor( Math.random() * 1000000 + 1)

if Meteor.isClient
  Meteor.startup ->
    assert = chai.assert

    setupEditor = (editorId) ->
      appendEditor editorId
      return new EditorState editorId

    #callback: (projectId) ->
    createFakeProject = (files, callback) ->
      Meteor.call 'createFakeProject', files, (error, result) ->
        Session.set "projectId", result.projectId
        assert.ok !error
        #console.log "created project:", result
        Deps.autorun (computation)->
          console.log "AUTORUNNIN'"
          if Files.find({projectId: result.projectId}).count() == files.length
            computation.stop()
            callback result

    #callback: (projectId) ->
    connectDementor = (projectId, callback) ->
      Meteor.http.post "#{Meteor.settings.public.boggartUrl}/socket/#{projectId}", (error, response) ->
        console.log "Returning from opening socket."
        console.error "open socket:", error.message if error
        assert.isNull error, "Unexpected error:", error
        console.log "Got response from POST socket."
        callback response

    disconnectDementor = (projectId, callback) ->
      Meteor.http.del "#{Meteor.settings.public.boggartUrl}/socket/#{projectId}", (error, response) ->
        console.log "Got response from DELETE socket with error:", error
        callback()


    #callback: ->
    addDementorFile = (file, callback) ->
      Meteor.http.post "#{Meteor.settings.public.boggartUrl}/file/#{file._id}", {
        data: {file: file}
        headers: {'Content-Type':'application/json'}
      }, (error, response) ->
        assert.isNull error
        console.log "Got response from POST file."
        callback()
        
    addDementorFiles = (files, callback) ->
      Meteor.http.post "#{Meteor.settings.public.boggartUrl}/files", {
        data: {files: files}
        headers: {'Content-Type':'application/json'}
      }, (error, response) ->
        assert.isNull error
        console.log "Got response from POST files."
        callback()
      

    #callback: (fileContents) ->
    getDementorFile = (fileId, callback) ->
      Meteor.http.get "#{Meteor.settings.public.boggartUrl}/file/#{fileId}", {
        headers: {'Content-Type':'application/json'}
      }, (error, response) ->
        assert.isNull error
        assert.ok response.data
        console.log "Got response from GET file:", response.data
        callback(response.data)

    describe "File Actions", ->
      @timeout 10000

      projectId = null
      Meteor.subscribe "fakeProject"
      Meteor.autosubscribe ->
        Meteor.subscribe "files", Projects.findOne()?._id

      describe "on request file", ->
        editorId = "editor" + randomId()

        file = null
        fileData =
          path : 'foo/load.txt'
          isDir : false
          contents : 'A happy duck is a warm duck.'
          aceMode: ->

        before (done) ->
          window.editorState = setupEditor editorId
          createFakeProject [fileData], (result) ->
            file = Files.findOne path: fileData.path
            projectId = result.projectId
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

        before (done) ->          
          editorState = setupEditor editorId

          createFakeProject [fileData], (result) ->
            file = Files.findOne path: fileData.path
            projectId = result.projectId
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

      describe 'on revert file', ->
        editorState = null
        editorId = "editor" + randomId()

        file = null
        fileData =
          path : 'foo/revert.txt'
          isDir : false
          contents : 'Sometimes, ducky is gone.'
          aceMode: ->

        before (done) ->
          createFakeProject [fileData], (result) ->
            projectId = result.projectId
            file = Files.findOne path: fileData.path
            editorState = setupEditor editorId

            connectDementor projectId, (response) ->
              addDementorFile file, ->
                editorState.loadFile file, (err) ->
                  assert.isNull err
                  editorState.getEditor().setValue "Something you should never see."
                  #give some time for this text to be inserted in shareJS
                  Meteor.setTimeout ->
                    editorState.revertFile done
                  , 250

        after (done) ->
          disconnectDementor projectId, done

        it "should revert the editor's content to the original", ->
          assert.equal ace.edit(editorId).getValue(), fileData.contents
        it "should leave dementor's file contents unchanged", (done) ->
          getDementorFile file._id, (data) ->
            assert.equal data.contents, fileData.contents
            done()
        it "should mark the file as unmodified", ->
          file = Files.findOne path: fileData.path
          assert.isFalse file.modified

      describe "on request file with weird line endings", ->
        editorState = null
        editorId = "editor" + randomId()


        #dos \r\n
        #mac \r
        #unix \n
        weirdFiles = {}
        weirdFileData = [{
            path : 'puredos'
            isDir : false
            contents : '1\r\n2\r\n3'
        }, {
            path : 'dosunix'
            isDir : false
            contents : '1\r\n2\n3'
        }, {
            path : 'dosunixmac'
            isDir : false
            contents : '1\r\n2\n3\r'
        }, {
            path : 'unixmac'
            isDir : false
            contents : '1\n2\r3'
        }, {
            path : 'dosmac'
            isDir : false
            contents : '1\r\n2\r3'
        }, {
            path : 'puremac'
            isDir : false
            contents : '1\r2\r3'
        }]

        before (done) ->
          editorState = setupEditor editorId

          createFakeProject weirdFileData, (result) ->
            projectId = result.projectId
            files = result.files
            #console.log "Retrieved files", files
            for f in files
              f = _.pick f, "_id", "projectId", "path", "orderingPath", "isDir"
              weirdFiles[f.path] = new MadEye.File f
            #console.log "Added weirdFiles:", weirdFiles
            connectDementor projectId, (response) ->
              addDementorFiles files, ->
                done()

        after (done) ->
          disconnectDementor projectId, done

        it 'should leave pure dos alone', (done) ->
          editorState.loadFile weirdFiles['puredos'], (err) ->
            assert.isNull err
            assert.equal ace.edit(editorId).getValue(), '1\r\n2\r\n3'
            done()

        it 'should leave pure mac alone', (done) ->
          editorState.loadFile weirdFiles['puremac'], (err) ->
            assert.isNull err
            assert.equal ace.edit(editorId).getValue(), '1\r2\r3'
            done()

        it 'should convert dosunix to unix', (done) ->
          editorState.loadFile weirdFiles['dosunix'], (err) ->
            assert.isNull err
            assert.equal ace.edit(editorId).getValue(), '1\n2\n3'
            done()

        it 'should convert dosunixmac to unix', (done) ->
          editorState.loadFile weirdFiles['dosunixmac'], (err) ->
            assert.isNull err
            assert.equal ace.edit(editorId).getValue(), '1\n2\n3\n'
            done()

        it 'should convert dosmac to dos', (done) ->
          editorState.loadFile weirdFiles['dosmac'], (err) ->
            assert.isNull err
            assert.equal ace.edit(editorId).getValue(), '1\r\n2\r\n3'
            done()

        it 'should convert unixmac to unix', (done) ->
          editorState.loadFile weirdFiles['unixmac'], (err) ->
            assert.isNull err
            assert.equal ace.edit(editorId).getValue(), '1\n2\n3'
            done()


  ###
      describe 'on discard file', ->
        it "should remove the file from the fileTree"
        it "should clear the editor"

  ###

