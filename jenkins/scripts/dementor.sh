export MADEYE_AZKABAN_HOST=localhost:4004
export MADEYE_AZKABAN_URL="http://"$MADEYE_AZKABAN_HOST
export MADEYE_APOGEE_URL="http://localhost:3000"
export MADEYE_HOME=$WORKSPACE

bin/init
bin/run_tests
