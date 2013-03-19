Meteor.startup ->
  if Meteor.isServer
    Meteor.publish "fakeProject", ->
      Projects.collection.find({test: true}, {sort: {date: -1}})

    Meteor.methods
      #TODO allow dir structure to be passed in
      createFakeProject: (files) ->
        @unblock()
        Projects.collection.remove {test: true}
        project = new Project
        project.test = true
        project.save()

        files ?= [{path:"README.md"}]
        for f in files
          file = new File f
          file.projectId = project._id
          file.modified_locally = f.modified_locally ? false
          file.isDir = f.isDir ? false
          file.modified = f.modified ? false
          file.save()

        return project._id
