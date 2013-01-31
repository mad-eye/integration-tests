contexts = {}

contexts.production =
  APOGEE_PORT : 3000
  APOGEE_URL : 'http://madeye.io'
  AZKABAN_PORT : 4004
  AZKABAN_HOST : 'madeye.io:4004'
  AZKABAN_URL : 'http://madeye.io:4004'
  BOLIDE_PORT : 3003
  BOLIDE_URL : 'http://madeye.io:3003/channel'
  MONGO_PORT : 27017
  MONGO_URL : 'mongodb://localhost:27017/meteor'
  KISS_METRICS_ID : '3bc3667a09a860b905eb64d7d4b76995b734eb8b'
  LOGGLY_AZKABAN_KEY : '813620cb-e0e6-441c-8301-41f4e26e0cae'

contexts.staging =
  APOGEE_PORT : 3000
  APOGEE_URL : 'http://staging.madeye.io:3000'
  AZKABAN_PORT : 4004
  AZKABAN_HOST : 'staging.madeye.io:4004'
  AZKABAN_URL : 'http://staging.madeye.io:4004'
  BOLIDE_PORT : 3003
  BOLIDE_URL : 'http://staging.madeye.io:3003/channel'
  MONGO_PORT : 27017
  MONGO_URL : 'mongodb://localhost:27017/meteor'
  KISS_METRICS_ID : '327a91cb91f272f073d2c6d4e9bdfc52e8dfa6a7'
  LOGGLY_AZKABAN_KEY : 'cb563a0e-fd2d-4340-85bf-ae2a2e811cc7'

contexts.apogee =
  name: "apogee"
  script: "exec /usr/bin/node /home/ubuntu/current-deploy/bundle/main.js"

contexts.azkaban =
  name: "azkaban"
  script: "exec /usr/bin/coffee /home/ubuntu/current-deploy/azkaban/app.coffee"

contexts.bolide =
  name: "bolide"
  script: "exec /usr/bin/node /home/ubuntu/current-deploy/bolide/app.js"

module.exports = contexts
