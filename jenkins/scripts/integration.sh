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

export MADEYE_HOME=$WORKSPACE

export MADEYE_APOGEE_PORT=3000
export MADEYE_APOGEE_URL="http://staging.madeye.io:"$MADEYE_APOGEE_PORT
export MADEYE_AZKABAN_PORT=4004
export MADEYE_AZKABAN_HOST="staging.madeye.io:"$MADEYE_AZKABAN_PORT
export MADEYE_AZKABAN_URL="http://"$MADEYE_AZKABAN_HOST
export MADEYE_BOLIDE_PORT=3003
export MADEYE_BOLIDE_URL="http://staging.madeye.io:"$MADEYE_BOLIDE_PORT
export MADEYE_MONGO_PORT=27017
export MADEYE_MONGO_URL="mongodb://localhost:"$MADEYE_MONGO_PORT"/meteor"

export MONGO_URL=$MADEYE_MONGO_URL
export PORT=$MADEYE_APOGEE_PORT
export MADEYE_KISS_METRICS_ID="9b307f5887365b1ecb4b47eb7625c69570d05b89"
export MADEYE_LOGGLY_AZKABAN_KEY="f924ff21-2026-49e7-ab43-4a079d7d1561"

sleep 10
coffee tests/testRunner.coffee

git commit -a -m "Updating submodule commits.  Automated by Jenkins." || echo "No changes found."
git push
