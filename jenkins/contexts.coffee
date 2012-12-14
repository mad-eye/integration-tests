fs = require 'fs'

apogeeScript = fs.readFileSync 'apogeeBuild.sh', 'utf-8'
azkabanScript = fs.readFileSync 'azkabanBuild.sh', 'utf-8'
bolideScript = fs.readFileSync 'bolideBuild.sh', 'utf-8'
dementorScript = fs.readFileSync 'dementorBuild.sh', 'utf-8'

contexts = {}

contexts.apogee_master =
  projectUrl: 'https://github.com/rissem/apogee/'
  gitUrl: 'git@github.com:rissem/apogee.git'
  branch: 'origin/master'
  script: apogeeScript

contexts.apogee_develop =
  projectUrl: 'https://github.com/rissem/apogee/'
  gitUrl: 'git@github.com:rissem/apogee.git'
  branch: 'origin/develop'
  script: apogeeScript

contexts.azkaban_master =
  projectUrl: 'https://github.com/rissem/azkaban/'
  gitUrl: 'git@github.com:rissem/azkaban.git'
  branch: 'origin/master'
  script: azkabanScript

contexts.azkaban_develop =
  projectUrl: 'https://github.com/rissem/azkaban/'
  gitUrl: 'git@github.com:rissem/azkaban.git'
  branch: 'origin/develop'
  script: azkabanScript

contexts.bolide_master =
  projectUrl: 'https://github.com/rissem/bolide/'
  gitUrl: 'git@github.com:rissem/bolide.git'
  branch: 'origin/master'
  script: bolideScript

contexts.bolide_develop =
  projectUrl: 'https://github.com/rissem/bolide/'
  gitUrl: 'git@github.com:rissem/bolide.git'
  branch: 'origin/develop'
  script: bolideScript

contexts.dementor_master =
  projectUrl: 'https://github.com/rissem/dementor/'
  gitUrl: 'git@github.com:rissem/dementor.git'
  branch: 'origin/master'
  script: dementorScript

contexts.dementor_develop =
  projectUrl: 'https://github.com/rissem/dementor/'
  gitUrl: 'git@github.com:rissem/dementor.git'
  branch: 'origin/develop'
  script: dementorScript

module.exports = contexts
  
