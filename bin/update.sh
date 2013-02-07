#! /bin/bash
set -e

#Update and check for changes
for dir in integration-tests apogee azkaban bolide dementor madeye-common; do
    pushd $dir
    git fetch
    git checkout develop
    if git log --oneline develop..origin/develop | wc -l | bc
    then
        echo "Unpulled changes found in $dir develop."
        git merge origin/develop
    fi

    #Check number of commits in master but not develop
    if git log --oneline master..develop | wc -l | bc
    then
        echo "Found unmerged changes in $dir master."
        git checkout master
        git merge origin/master
        git checkout develop
        git merge master
        git push
    fi
    popd
done

for dir in madeye-dev madeye-ops; do
    pushd $dir
    git pull
    popd
done

