appendEditor = (editorId) ->
  $("<p><div id='#{editorId}' style='height:40px; width: 300px'></div></p>").appendTo document.body


Meteor.startup ->
  if Meteor.isClient
    describe "EditorState loadFile", ->
      Meteor.subscribe "fakeProject"
      Meteor.autosubscribe ->
        Meteor.subscribe "files", Projects.findOne()?._id

      assert = chai.assert

      before (done)->
        Meteor.call "createFakeProject", [{path: "README.md"}, {path: "settings.json"}],  (err)->
          done()

      it "populate the editor", (done)->
        editorId = "fakeEditor1"
        appendEditor editorId
        file = Files.findOne path: "README.md"
        bolide.create file._id, ->
          bolide.set file._id, "new doc contents", ->
            editorState = new EditorState(editorId)
            editorState.loadFile file, ->
              assert.equal ace.edit(editorId).getValue(), "new doc contents"
              done()

        #TODO cleanup (remove the editor, detach ace)

      it "populates the editor again", (done)->
        editorId = "fakeEditor2"
        appendEditor editorId
        file = Files.findOne path: "settings.json"
        bolide.create file._id, ->
          bolide.set file._id, "{\"blah\":false}", ->
            editorState = new EditorState(editorId)
            editorState.loadFile file, ->
              assert.equal ace.edit(editorId).getValue(), "{\"blah\":false}"
              done()
              
