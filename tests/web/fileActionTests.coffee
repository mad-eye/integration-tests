log = new MadEye.Logger 'fileActionTests'

randomId = () ->
  return Math.floor( Math.random() * 1000000 + 1)

Meteor.startup ->
  if Meteor.isServer
    files = {}

    @Projects.allow
      insert: ->
        true

    MadEye.summonDementor = (projectId)->
      requestFile: (fileId)->
        #TODO also set checksums..
        return {contents: files[fileId]}

      saveFile: (fileId, contents)->
        files[fileId] = contents 

    Meteor.methods
      setFileContents: (fileId, contents)->
        log.trace "Setting file #{fileId} contents to", contents
        files[fileId] = contents
        return contents #figure out what should be returned here..

      getFileContents: (fileId)->
        log.trace "Getting file #{fileId} contents:", files[fileId]
        files[fileId]

      bulkSetContents: (map)->
        for fileId, contents of map
          files[fileId] = contents
        
if Meteor.isClient
  addFiles = (projectId, files=[]) ->
    savedFiles = []
    for f in files
      file = new MadEye.File f
      file.projectId =  projectId
      file.modified_locally = f.modified_locally ? false
      file.isDir = f.isDir ? false
      file.modified = f.modified ? false
      file.save()
      savedFiles.push file
    return savedFiles

  contents = {}

  createFakeProject = (files) ->
    project = new Project
    project.test = true
    project.name = 'testProject'
    project.save()
    Session.set "projectId", project._id
    files = addFiles project._id, files
    return project

  Meteor.startup ->
    assert = chai.assert

    setupEditor = (editorId) ->
      appendEditor editorId
      editorState = new EditorState editorId
      editorState.attach editorId
      return editorState

    describe "File Actions", ->
      @timeout 10000

      projectId = null
      describe "on request file", ->
        editorId = "editor" + randomId()

        file = null
        fileData =
          path : 'foo/load.txt'
          orderingPath : 'foo/load.txt'
          isDir : false
          contents : 'A happy duck is a warm duck.'

        before (done)->
          window.editorState = setupEditor editorId
          project = createFakeProject [fileData]
          file = Files.findOne path: fileData.path
          projectId = project._id
          Meteor.call "setFileContents", file._id, fileData.contents, done

        it 'should set editor body to contents', (done) ->
          Meteor.setTimeout ->
            editorState.loadFile file, (err) ->
              assert.isNull err
              assert.equal ace.edit(editorId).getValue(), fileData.contents
              done()
          , 200

      describe 'on save file', ->
        editorState = null
        editorId = "editor" + randomId()

        file = null
        fileData =
          path : 'foo/save.txt'
          orderingPath : 'foo/save.txt'
          isDir : false
          contents : 'A happy duck is a warm duck.'

        newContents = "Run for the hills, little ducky."

        before (done) ->
          editorState = setupEditor editorId

          project = createFakeProject [fileData]
          file = Files.findOne path: fileData.path
          projectId = project._id
          Meteor.call "setFileContents", file._id, fileData.contents, ->
            editorState.loadFile file, (err) ->
              assert.isNull err
              editorState.getEditor().setValue newContents
              editorState.save done

        it "should replace the local file's content", (done) ->
          Meteor.call "getFileContents", file._id, (err, result)->
            assert.equal result, newContents
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
          orderingPath : 'foo/revert.txt'
          isDir : false
          contents : 'Sometimes, ducky is gone.'

        before (done) ->
          project = createFakeProject [fileData]
          projectId = project._id
          file = Files.findOne path: fileData.path
          editorState = setupEditor editorId

          Meteor.call "setFileContents", file._id, fileData.contents, ->
            editorState.loadFile file, (err) ->
              assert.isNull err
              editorState.getEditor().setValue "Something you should never see."
              #give some time for this text to be inserted in shareJS
              Meteor.setTimeout ->
                editorState.revertFile done
              , 250

        it "should revert the editor's content to the original", ->
          assert.equal ace.edit(editorId).getValue(), fileData.contents
        it "should leave dementor's file contents unchanged", (done) ->
          Meteor.call "getFileContents", file._id, (err, contents) ->
            assert.equal contents, fileData.contents
            done()
        it "should mark the file as unmodified", ->
          file = Files.findOne path: fileData.path
          assert.isFalse file.modified

      # describe "on request file with weird line endings", ->
      #   editorState = null
      #   editorId = "editor" + randomId()

      #   #dos \r\n
      #   #mac \r
      #   #unix \n
      #   weirdFiles = {}
      #   weirdFileData = [{
      #       path : 'puredos'
      #       isDir : false
      #       contents : '1\r\n2\r\n3'
      #   }, {
      #       path : 'dosunix'
      #       isDir : false
      #       contents : '1\r\n2\n3'
      #   }, {
      #       path : 'dosunixmac'
      #       isDir : false
      #       contents : '1\r\n2\n3\r'
      #   }, {
      #       path : 'unixmac'
      #       isDir : false
      #       contents : '1\n2\r3'
      #   }, {
      #       path : 'dosmac'
      #       isDir : false
      #       contents : '1\r\n2\r3'
      #   }, {
      #       path : 'puremac'
      #       isDir : false
      #       contents : '1\r2\r3'
      #   }]

        # before (done) ->
        #   editorState = setupEditor editorId

        #   project = createFakeProject weirdFileData
        #   projectId = project._id
        #   files = Files.find {projectId: project._id}
        #   idMap = {}
        #   files.forEach (f)->
        #     weirdFiles[f.path] = f
        #     idMap[f._id] = f.contents
        #   Meteor.call "bulkSetContents", idMap, (err, result)->
        #     done()

        # it 'should leave pure dos alone', (done) ->
        #   editorState.loadFile weirdFiles['puredos'], (err) ->
        #     assert.equal ace.edit(editorId).getValue(), '1\r\n2\r\n3'
        #     done()

        # it 'should leave pure mac alone', (done) ->
        #   editorState.loadFile weirdFiles['puremac'], (err) ->
        #     assert.isNull err
        #     assert.equal ace.edit(editorId).getValue(), '1\r2\r3'
        #     done()

        # it 'should convert dosunix to unix', (done) ->
        #   editorState.loadFile weirdFiles['dosunix'], (err) ->
        #     assert.isNull err
        #     assert.equal ace.edit(editorId).getValue(), '1\n2\n3'
        #     done()

        # it 'should convert dosunixmac to unix', (done) ->
        #   editorState.loadFile weirdFiles['dosunixmac'], (err) ->
        #     assert.isNull err
        #     assert.equal ace.edit(editorId).getValue(), '1\n2\n3\n'
        #     done()

        # it 'should convert dosmac to dos', (done) ->
        #   editorState.loadFile weirdFiles['dosmac'], (err) ->
        #     assert.isNull err
        #     assert.equal ace.edit(editorId).getValue(), '1\r\n2\r\n3'
        #     done()

        # it 'should convert unixmac to unix', (done) ->
        #   editorState.loadFile weirdFiles['unixmac'], (err) ->
        #     assert.isNull err
        #     assert.equal ace.edit(editorId).getValue(), '1\n2\n3'
        #     done()

  ###
      describe 'on discard file', ->
        it "should remove the file from the fileTree"
        it "should clear the editor"

  ###

