Meteor.startup ->
  if Meteor.isServer

    addFiles = (projectId, files=[]) ->
      for f in files
        file = new File f
        file.projectId =  projectId
        file.modified_locally = f.modified_locally ? false
        file.isDir = f.isDir ? false
        file.modified = f.modified ? false
        file.save()
      console.log "added files", files
      return files


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

        addFiles project._id, files
        return project._id

      addFakeFiles: (projectId, files) ->
        @unblock()
        return addFiles projectId, files
        

