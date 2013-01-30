set -x
git checkout $GIT_BRANCH
sh $WORKSPACE/bin/init
for dir in apogee azkaban bolide dementor; do
    bin=bin
    if [ "$dir" = "apogee" ]; then
        bin=.bin
    fi
    cd $WORKSPACE/$dir
    git fetch
    git checkout $GIT_BRANCH
    $WORKSPACE/$dir/$bin/init
done
cd $WORKSPACE


cd $WORKSPACE && ./deploy.rb --ec2 --branch=$GIT_BRANCH

export MADEYE_BC_HOST=staging.madeye.io
export MADEYE_BC_PORT=4321
export MADEYE_HTTP_HOST=staging.madeye.io
export MADEYE_HTTP_PORT=4004
export MADEYE_APOGEE_HOST=staging.madeye.io
export MADEYE_APOGEE_PORT=3000
export MADEYE_HOME=$WORKSPACE
export MADEYE_LOGGLY_AZKABAN_KEY=cb563a0e-fd2d-4340-85bf-ae2a2e811cc7

sleep 10
coffee tests/testRunner.coffee

git commit -a -m "Updating submodule commits.  Automated by Jenkins." || echo "No changes found."
git push
