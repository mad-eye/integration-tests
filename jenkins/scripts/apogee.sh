cd .madeye-common
jake compile
cd ..
METEOR_CLIENT_TEST=true mrt &> /tmp/mrtLog &
sleep 60
#TODO: Replace these with env variables?
mocha-phantomjs http://localhost:3000/tests
