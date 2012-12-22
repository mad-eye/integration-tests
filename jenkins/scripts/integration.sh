set -x
git checkout $GIT_BRANCH
sh $WORKSPACE/bin/init.sh
for dir in apogee azkaban bolide dementor; do
    cd $WORKSPACE/$dir && git checkout $GIT_BRANCH && git pull && cd $WORKSPACE
done

# TODO use this script? ./updateSubmodules.sh
cd $WORKSPACE/azkaban && git submodule update --init .madeye-common
cd $WORKSPACE/apogee && git submodule update --init .madeye-common
cd $WORKSPACE/dementor && git submodule update --init .madeye-common
cd $WORKSPACE && ./deploy.rb --ec2 --branch=$GIT_BRANCH

export MADEYE_BC_HOST=staging.madeye.io
export MADEYE_BC_PORT=4321
export MADEYE_HTTP_HOST=staging.madeye.io
export MADEYE_HTTP_PORT=4004
export MADEYE_APOGEE_HOST=staging.madeye.io
export MADEYE_APOGEE_PORT=3000

cd $WORKSPACE/dementor && npm install .madeye-common
cd $WORKSPACE/dementor && npm install
coffee tests/testRunner.coffee

git commit -a -m "Updating submodule commits.  Automated by Jenkins." || echo "No changes found."
git push
