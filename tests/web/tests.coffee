Meteor.startup ->
  if Meteor.isClient
    describe "big picture stuff", ->
      Meteor.subscribe "fakeProject"
      Meteor.autosubscribe ->
        Meteor.subscribe "files", Projects.findOne()?._id

      assert = chai.assert

      before (done)->
        Meteor.call "createFakeProject", (err)->
          done()

      it "does other stuff", (done)->
        editorId = "fakeEditor1"
        file = Files.findOne()
        bolide.create file._id, ->
          bolide.set file._id, "new doc contents", ->
            editorState = new EditorState(editorId)
            editorState.loadFile file, ->
              assert.equal ace.edit(editorId).getValue(), "new doc contents"
              done()
