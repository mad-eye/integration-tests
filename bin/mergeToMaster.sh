#! /bin/sh
set -e

git fetch
git checkout develop
git merge origin/develop
for dir in apogee azkaban bolide dementor madeye-common; do
    #TODO: Bump dementor version -- But how much?
    cd $dir
    git fetch
    git checkout master
    git merge origin/master
    git checkout develop
    git merge origin/develop
    git merge master
    echo "Press return to continue, or cancel if this wasn't a no-op"
    read dummy_var
    git checkout master
    git merge develop
    git push
    cd ..
done

git checkout master
git merge origin/master
git merge --no-ff --no-commit develop
bin/init

#TODO: Automatically push ops config files to production?

echo "Please run tests then commit."
echo "If you have modified any files in madeye-ops, please push those to production."
echo "(For example, /etc/init/*.conf scripts, nginx configurations, etc)"

