#! /bin/bash
set -e


#TODO: Bump dementor and madeye-common version -- But how much?

CHANGES=0

#Update and check for changes
for dir in "." apogee azkaban bolide dementor madeye-common; do
    pushd $dir
    git fetch
    git checkout develop
    if git log --oneline origin/develop..develop | wc -l | bc
    then
        echo "Unpulled changes found in $dir develop."
        CHANGES=1
        git merge origin/develop
    fi

    #Check number of commits in master but not develop
    if git log --oneline master..develop | wc -l | bc
    then
        echo "Found unmerged changes in $dir master."
        CHANGES=1
        git checkout master
        git merge origin/master
        git checkout develop
        git merge master
        git push
    fi
    popd
done

if [ $CHANGES ]; then
    echo "Commits needed for develop found, exiting."
    echo "Please test the new configuration and run again."
    exit $CHANGES
fi

for dir in apogee azkaban bolide dementor madeye-common; do
    pushd $dir
    git checkout master
    git merge develop
    git push
    popd
done

git checkout master
git merge --no-ff --no-commit develop
bin/init

#TODO: Automatically push ops config files to production?

echo "Please run tests then commit."
echo "If you have modified any files in madeye-ops, please push those to production."
echo "(For example, /etc/init/*.conf scripts, nginx configurations, etc)"

