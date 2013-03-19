Meteor.startup ->
  if Meteor.isClient
    describe "big picture stuff", ->
      Meteor.subscribe "fakeProject"
      Meteor.autosubscribe ->
        Meteor.subscribe "files", Projects.findOne()?._id

      assert = chai.assert

      before (done)->
        Meteor.call "createFakeProject", [{path: "README.md"}, {path: "settings.json"}],  (err)->
          done()

      it "does other stuff", (done)->
        editorId = "fakeEditor1"
        #TODO extract method for creating/appending editor DOM
        $("<p><div id='#{editorId}' style='height:40px; width: 300px'></div></p>").appendTo document.body
        file = Files.findOne path: "README.md"
        bolide.create file._id, ->
          bolide.set file._id, "new doc contents", ->
            editorState = new EditorState(editorId)
            editorState.loadFile file, ->
              assert.equal ace.edit(editorId).getValue(), "new doc contents"
              done()

        #TODO cleanup (remove the editor, detach ace)

      it "does even more stuff", (done)->
        editorId = "fakeEditor2"
        $("<p><div id='#{editorId}' style='width:300px; height: 40px'></div></p>").appendTo document.body
        file = Files.findOne path: "settings.json"
        bolide.create file._id, ->
          bolide.set file._id, "{\"blah\":false}", ->
            editorState = new EditorState(editorId)
            editorState.loadFile file, ->
              assert.equal ace.edit(editorId).getValue(), "{\"blah\":false}"
              done()
              

