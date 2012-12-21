git checkout $GIT_BRANCH
# TODO use this script? ./updateSubmodules.sh
cd $WORKSPACE/azkaban && git submodule update --init .madeye-common
cd $WORKSPACE/apogee && git submodule update --init .madeye-common
./deploy.rb --ec2 --branch=$GIT_BRANCH
#RUN TESTS HERE
git commit -a -m "Updating submodule commits.  Automated by Jenkins." || echo "No changes found."
git push

