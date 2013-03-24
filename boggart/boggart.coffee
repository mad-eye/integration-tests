express = require('express')
http = require('http')
io = require 'socket.io-client'
{Settings, messageAction} = require 'madeye-common'
cors = require './cors'

console.log "Using messageAction:", messageAction

app = express()

app.configure =>
  app.set('port', 4999)
  app.use(express.logger('dev'))
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(cors())
  app.use(app.router)
  app.use(express.errorHandler())

httpServer = http.createServer(app)

#projectId : socket
sockets = {}

#fileId : file
#file.error : error to return instead of normal results
#file.contents : file contents, to be read or saved over
files = {}

app.post '/socket/:projectId', (req, res) ->
  projectId = req.params.projectId
  console.log "Creating socket for projectId", projectId
  sockets[projectId] = socket = io.connect Settings.azkabanUrl,
    'resource': 'socket.io' #NB: This must match the server.  Server defaults to 'socket.io'
    'force new connection':true
    #'auto connect': false

  socket.on 'connect', ->
    console.log "Socket #{projectId} handshaking."
    socket.emit messageAction.HANDSHAKE, projectId, (err) ->
      console.log "Socket #{projectId} handshook."
      res.end(projectId)

  #socket.socket.connect ->
    #console.log "Socket #{projectId} connected."

  socket.on 'error', (reason) ->
    console.error "Socket Error:", reason

  #callback: (err, body) =>, errors are encoded as {error:}
  socket.on messageAction.REQUEST_FILE, (data, callback) ->
    console.log "Requested local file", data
    fileId = data.fileId
    unless fileId then callback errors.new 'MISSING_PARAM'; return
    file = files[fileId]
    callback file.error, file.contents

  #callback: (err) =>, errors are encoded as {error:}
  socket.on messageAction.SAVE_LOCAL_FILE, (data, callback) ->
    console.log "Saving local file", data
    fileId = data.fileId
    contents = data.contents
    unless fileId && contents?
      callback errors.new 'MISSING_PARAM'; return
    file = files[fileId]
    unless file.error?
      file.contents = contents
    callback file.error

app.del '/socket/:projectId', (req, res) ->
  projectId = req.params.projectId
  console.log "Removing socket for", projectId
  socket = sockets[projectId]
  delete sockets[projectId]
  socket?.disconnect()
  res.end()

app.post '/message/localFilesAdded/:projectId', (req, res) ->
  projectId = req.params.projectId
  socket = projectId
  data =
    projectId : projectId
    files : req.body.files
  socket.emit messageAction.LOCAL_FILES_ADDED, data, (err) ->
    res.end()


app.post '/message/localFilesSaved/:projectId', (req, res) ->
  projectId = req.params.projectId
  socket = projectId
  data =
    projectId : projectId
    file : req.body.file
    contents: req.body.file.contents
  socket.emit messageAction.LOCAL_FILE_SAVED, data, (err) ->
    res.end()


app.post '/message/localFilesRemoved/:projectId', (req, res) ->
  projectId = req.params.projectId
  socket = projectId
  data =
    projectId : projectId
    files : req.body.files
  socket.emit messageAction.LOCAL_FILES_REMOVED, data, (err) ->
    res.end()

app.post '/message/:projectId/:action', (req, res)->
  projectId = req.params.projectId
  action = req.params.action
  data = req.body
  res.end()

app.post '/file/:fileId', (req, res) ->
  fileId = req.params.fileId
  file = req.body.file
  file._id = fileId
  console.log "POST file", file.path
  files[fileId] = file
  res.end()

app.get '/file/:fileId', (req, res) ->
  console.log "GET file", req.params.fileId
  res.json files[req.params.fileId]
  res.end()

httpServer.listen app.get('port'), ->
  console.log "Boggart listening on port " + app.get('port')
