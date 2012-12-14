METEOR_CLIENT_TEST=true mrt &> /tmp/mrtLog &
sleep 60
mocha-phantomjs http://localhost:3000/tests
