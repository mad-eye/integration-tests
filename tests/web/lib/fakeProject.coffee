Meteor.startup ->
  if Meteor.isServer
    Meteor.publish "fakeProject", ->
      Projects.collection.find({test: true}, {sort: {date: -1}})

    Meteor.methods
      #TODO allow dir structure to be passed in
      createFakeProject: ->
        console.log "creating fake project"
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
