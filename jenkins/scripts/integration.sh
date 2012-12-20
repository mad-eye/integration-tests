printenv
git checkout $GIT_BRANCH
./updateSubmodules.sh
ls -la
./deploy.rb --ec2 --branch=$GIT_BRANCH
#RUN TESTS HERE
git commit -a -m "Updating submodule commits.  Automated by Jenkins." || echo "No changes found."
git push

