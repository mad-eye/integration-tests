fs = require 'fs'

apogeeScript = fs.readFileSync 'scripts/apogee.sh', 'utf-8'
azkabanScript = fs.readFileSync 'scripts/azkaban.sh', 'utf-8'
bolideScript = fs.readFileSync 'scripts/bolide.sh', 'utf-8'
dementorScript = fs.readFileSync 'scripts/dementor.sh', 'utf-8'
integrationScript = fs.readFileSync 'scripts/integration.sh', 'utf-8'
commonScript = fs.readFileSync 'scripts/common.sh', 'utf-8'

contexts = {}

#Need to use [] because '-' is not a valid key char
contexts['madeye-common_master'] =
  projectUrl: 'https://github.com/mad-eye/madeye-common/'
  gitUrl: 'git@github.com:mad-eye/madeye-common.git'
  branch: 'origin/master'
  refSpec: '+refs/heads/master:refs/remotes/origin/master'
  script: commonScript
  childProjects: ['apogee_master', 'azkaban_master', 'bolide_master', 'dementor_master']

contexts['madeye-common_develop'] =
  projectUrl: 'https://github.com/mad-eye/madeye-common/'
  gitUrl: 'git@github.com:mad-eye/madeye-common.git'
  branch: 'origin/develop'
  refSpec: '+refs/heads/develop:refs/remotes/origin/develop'
  script: commonScript
  childProjects: ['apogee_develop', 'azkaban_develop', 'bolide_develop', 'dementor_develop']

contexts.apogee_master =
  projectUrl: 'https://github.com/mad-eye/apogee/'
  gitUrl: 'git@github.com:mad-eye/apogee.git'
  branch: 'origin/master'
  refSpec: '+refs/heads/master:refs/remotes/origin/master'
  script: apogeeScript
  childProjects: ['integration-tests_master']

contexts.apogee_develop =
  projectUrl: 'https://github.com/mad-eye/apogee/'
  gitUrl: 'git@github.com:mad-eye/apogee.git'
  branch: 'origin/develop'
  refSpec: '+refs/heads/develop:refs/remotes/origin/develop'
  script: apogeeScript
  childProjects: ['integration-tests_develop']

contexts.azkaban_master =
  projectUrl: 'https://github.com/mad-eye/azkaban/'
  gitUrl: 'git@github.com:mad-eye/azkaban.git'
  branch: 'origin/master'
  refSpec: '+refs/heads/master:refs/remotes/origin/master'
  script: azkabanScript
  childProjects: ['integration-tests_master']

contexts.azkaban_develop =
  projectUrl: 'https://github.com/mad-eye/azkaban/'
  gitUrl: 'git@github.com:mad-eye/azkaban.git'
  branch: 'origin/develop'
  refSpec: '+refs/heads/develop:refs/remotes/origin/develop'
  script: azkabanScript
  childProjects: ['integration-tests_develop']

contexts.bolide_master =
  projectUrl: 'https://github.com/mad-eye/bolide/'
  gitUrl: 'git@github.com:mad-eye/bolide.git'
  branch: 'origin/master'
  refSpec: '+refs/heads/master:refs/remotes/origin/master'
  script: bolideScript
  childProjects: ['integration-tests_master']

contexts.bolide_develop =
  projectUrl: 'https://github.com/mad-eye/bolide/'
  gitUrl: 'git@github.com:mad-eye/bolide.git'
  branch: 'origin/develop'
  refSpec: '+refs/heads/develop:refs/remotes/origin/develop'
  script: bolideScript
  childProjects: ['integration-tests_develop']

contexts.dementor_master =
  projectUrl: 'https://github.com/mad-eye/dementor/'
  gitUrl: 'git@github.com:mad-eye/dementor.git'
  branch: 'origin/master'
  refSpec: '+refs/heads/master:refs/remotes/origin/master'
  script: dementorScript
  childProjects: ['integration-tests_master']

contexts.dementor_develop =
  projectUrl: 'https://github.com/mad-eye/dementor/'
  gitUrl: 'git@github.com:mad-eye/dementor.git'
  branch: 'origin/develop'
  refSpec: '+refs/heads/develop:refs/remotes/origin/develop'
  script: dementorScript
  childProjects: ['integration-tests_develop']

contexts['integration-tests_master'] =
  projectUrl: 'https://github.com/mad-eye/integration-tests/'
  gitUrl: 'git@github.com:mad-eye/integration-tests.git'
  branch: 'origin/master'
  refSpec: '+refs/heads/master:refs/remotes/origin/master'
  script: integrationScript
  description: 'test that all apogee, azkaban, bolide, and dementor are all working together'

contexts['integration-tests_develop'] =
  projectUrl: 'https://github.com/mad-eye/integration-tests/'
  gitUrl: 'git@github.com:mad-eye/integration-tests.git'
  branch: 'origin/develop'
  refSpec: '+refs/heads/develop:refs/remotes/origin/develop'
  script: integrationScript
  description: 'test that all apogee, azkaban, bolide, and dementor are all working together'

module.exports = contexts
