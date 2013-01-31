.bin/init
METEOR_MOCHA_TEST_DIR="$PWD/client/tests" mrt &> /tmp/mrtLog &
sleep 60
#TODO: Replace these with env variables?
mocha-phantomjs http://localhost:3000/tests
