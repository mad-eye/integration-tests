#! /bin/bash
set -e

#Update and check for changes
for dir in integration-tests apogee azkaban bolide dementor madeye-common; do
    pushd $dir >/dev/null
    git fetch
    git checkout develop
    numChanges=$(git log --oneline develop..origin/develop | wc -l | bc)
    if [ $numChanges -gt 0 ]; then
        echo "Unpulled changes found in $dir develop."
        git merge origin/develop
    fi

    #Check number of commits in master but not develop
    numChanges=$(git log --oneline develop..master | wc -l | bc)
    if [ $numChanges -gt 0 ]; then
        echo "Found unmerged changes in $dir master."
        git checkout master
        git merge origin/master
        git checkout develop
        git merge master
        git push
    fi
    popd >/dev/null
done

for dir in madeye-dev madeye-ops; do
    pushd $dir >/dev/null
    git pull
    popd >/dev/null
done

