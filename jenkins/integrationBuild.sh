printenv
git checkout $GIT_BRANCH
git submodule foreach "git checkout $GIT_BRANCH"
ls -la
./deploy.rb --ec2 --branch=$GIT_BRANCH
#RUN TESTS HERE
git commit -a -m "Updating submodule commits.  Automated by Jenkins." || echo "No changes found."
