Meteor.startup ->
  if Meteor.isServer

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
      #console.log "added files", savedFiles
      return savedFiles


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

        files = addFiles project._id, files
        return projectId: project._id, files: files

      addFakeFiles: (projectId, files) ->
        @unblock()
        return addFiles projectId, files
        

