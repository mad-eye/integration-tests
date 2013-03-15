Meteor.startup ->
  if Meteor.isServer
    bolideUrl = Meteor.settings.public.bolideUrl
    bolide =
      create: (name, callback)->
        Meteor.http.put "#{bolideUrl}/doc/#{name}", data: {type: "text2"}

      modify: (name, version, ops)->
        Meteor.http.post "#{bolideUrl}/doc/#{name}?v=#{version}", data: ops

      set: (name, contents)->
        version = bolide.snapshot(name).headers["x-ot-version"]
        #TODO delete something if its already there
        bolide.modify name, version, [contents]

      snapshot: (name)->
        Meteor.http.get "#{bolideUrl}/doc/#{name}", {type: "text2"}

    Meteor.publish "fakeProject", ->
      Projects.collection.find({test: true}, {sort: {date: -1}})

    Meteor.methods
      createFakeProject: ->
        @unblock()
        Projects.collection.remove {test: true}
        project = new Project
        project.test = true
        project.save()

        file1 = new File
        file1.projectId = project._id
        file1.path = "README.md"
        file1.modified_locally = false
        file1.isDir = false
        file1.modified = false
        file1.save()

        result = bolide.create file1._id
        bolide.set file1._id, "this is an important document that you should read"
#        console.log bolide.snapshot file1._id
  
  describe "big picture stuff", ->
    Meteor.subscribe "fakeProject"
    Meteor.autosubscribe ->
      Meteor.subscribe "files", Projects.findOne()?._id

    assert = chai.assert

    before (done)->
      Meteor.call "createFakeProject", (err)->
        done()
      
    it "does other stuff", ->
      file = Files.findOne()
      window.editorState = new EditorState()
      editorState.setPath file.path
      document.body.appendChild Meteor.render(Template.editor)
      Session.set "editorRendered", true

