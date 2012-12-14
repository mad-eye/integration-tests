printenv

export MADEYE_BC_HOST=localhost
export MADEYE_BC_PORT=4321
export MADEYE_HTTP_HOST=localhost
export MADEYE_HTTP_PORT=4004
export MADEYE_MONGO_HOST=localhost
export MADEYE_MONGO_PORT=27017
export MADEYE_APOGEE_HOST=localhost
export MADEYE_APOGEE_PORT=3000
export MADEYE_BOLIDE_HOST=localhost
export MADEYE_BOLIDE_PORT=3003

npm install
PATH="$PATH:./bin"
run_tests
#curl -u jenkins:f58c6760c9e90968fd673feebf1c6216 "http://ci.madeye.io:8080/job/madeye-integration/buildWithParameters?token=CAT&modifiedBranch=$GIT_BRANCH"
