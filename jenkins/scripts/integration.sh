set -x
git checkout $GIT_BRANCH
sh $WORKSPACE/bin/init.sh
for dir in apogee azkaban bolide dementor; do
    cd $WORKSPACE/$dir && git checkout $GIT_BRANCH && git pull && cd $WORKSPACE
done
cd $WORKSPACE && ./deploy.rb --ec2 --branch=$GIT_BRANCH
#RUN TESTS HERE
git commit -a -m "Updating submodule commits.  Automated by Jenkins." || echo "No changes found."
git push
