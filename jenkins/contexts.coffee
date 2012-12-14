fs = require 'fs'

apogeeScript = fs.readFileSync 'apogeeBuild.sh', 'utf-8'
azkabanScript = fs.readFileSync 'azkabanBuild.sh', 'utf-8'
bolideScript = fs.readFileSync 'bolideBuild.sh', 'utf-8'
dementorScript = fs.readFileSync 'dementorBuild.sh', 'utf-8'
integrationScript = fs.readFileSync 'integrationBuild.sh', 'utf-8'
commonScript = fs.readFileSync 'commonBuild.sh', 'utf-8'

contexts = {}

#Need to use [] because '-' is not a valid key char
contexts['madeye-common_master'] =
  projectUrl: 'https://github.com/mad-eye/madeye-common/'
  gitUrl: 'git@github.com:mad-eye/madeye-common.git'
  branch: 'origin/master'
  refSpec: 'master'
  script: commonScript
  childProjects: ['apogee_master', 'azkaban_master', 'bolide_master', 'dementor_master']

contexts['madeye-common_develop'] =
  projectUrl: 'https://github.com/mad-eye/madeye-common/'
  gitUrl: 'git@github.com:mad-eye/madeye-common.git'
  branch: 'origin/develop'
  refSpec: 'develop'
  script: commonScript
  childProjects: ['apogee_develop', 'azkaban_develop', 'bolide_develop', 'dementor_develop']

contexts.apogee_master =
  projectUrl: 'https://github.com/rissem/apogee/'
  gitUrl: 'git@github.com:rissem/apogee.git'
  branch: 'origin/master'
  refSpec: 'master'
  script: apogeeScript
  childProjects: ['integration-tests_master']

contexts.apogee_develop =
  projectUrl: 'https://github.com/rissem/apogee/'
  gitUrl: 'git@github.com:rissem/apogee.git'
  branch: 'origin/develop'
  refSpec: 'develop'
  script: apogeeScript
  childProjects: ['integration-tests_develop']

contexts.azkaban_master =
  projectUrl: 'https://github.com/rissem/azkaban/'
  gitUrl: 'git@github.com:rissem/azkaban.git'
  branch: 'origin/master'
  refSpec: 'master'
  script: azkabanScript
  childProjects: ['integration-tests_master']

contexts.azkaban_develop =
  projectUrl: 'https://github.com/rissem/azkaban/'
  gitUrl: 'git@github.com:rissem/azkaban.git'
  branch: 'origin/develop'
  refSpec: 'develop'
  script: azkabanScript
  childProjects: ['integration-tests_develop']

contexts.bolide_master =
  projectUrl: 'https://github.com/rissem/bolide/'
  gitUrl: 'git@github.com:rissem/bolide.git'
  branch: 'origin/master'
  refSpec: 'master'
  script: bolideScript
  childProjects: ['integration-tests_master']

contexts.bolide_develop =
  projectUrl: 'https://github.com/rissem/bolide/'
  gitUrl: 'git@github.com:rissem/bolide.git'
  branch: 'origin/develop'
  refSpec: 'develop'
  script: bolideScript
  childProjects: ['integration-tests_develop']

contexts.dementor_master =
  projectUrl: 'https://github.com/rissem/dementor/'
  gitUrl: 'git@github.com:rissem/dementor.git'
  branch: 'origin/master'
  refSpec: 'master'
  script: dementorScript
  childProjects: ['integration-tests_master']

contexts.dementor_develop =
  projectUrl: 'https://github.com/rissem/dementor/'
  gitUrl: 'git@github.com:rissem/dementor.git'
  branch: 'origin/develop'
  refSpec: 'develop'
  script: dementorScript
  childProjects: ['integration-tests_develop']

contexts['integration-tests_master'] =
  projectUrl: 'https://github.com/mad-eye/integration-tests/'
  gitUrl: 'git@github.com:mad-eye/integration-tests.git'
  branch: 'origin/master'
  refSpec: 'master'
  script: integrationScript
  description: 'test that all apogee, azkaban, bolide, and dementor are all working together'

contexts['integration-tests_develop'] =
  projectUrl: 'https://github.com/mad-eye/integration-tests/'
  gitUrl: 'git@github.com:mad-eye/integration-tests.git'
  branch: 'origin/develop'
  refSpec: 'develop'
  script: integrationScript
  description: 'test that all apogee, azkaban, bolide, and dementor are all working together'

module.exports = contexts
  
