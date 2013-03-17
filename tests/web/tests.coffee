Meteor.startup ->
  if Meteor.isClient
    describe "big picture stuff", ->
      Meteor.subscribe "fakeProject"
      Meteor.autosubscribe ->
        Meteor.subscribe "files", Projects.findOne()?._id

      assert = chai.assert

      before (done)->
        Meteor.call "createFakeProject", (err)->
          console.log("HOLLER", err);
          done()

      it "does other stuff", ->
        file = Files.findOne()
        window.editorState = new EditorState()
        editorState.setPath file.path
        document.body.appendChild Meteor.render(Template.editor)
        Session.set "editorRendered", true

