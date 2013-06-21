#! /bin/bash
set -e

#Update and check for changes
git checkout develop
git pull
for dir in apogee azkaban bolide dementor madeye-common madeye-ops nurmengard hermione; do
    echo Entering $dir
    pushd $dir >/dev/null
    git fetch
    git checkout develop
    numChanges=$(git log --oneline develop..origin/develop | wc -l | bc)
    if [ $numChanges -gt 0 ]; then
        echo "Unpulled changes found in $dir develop."
        git merge origin/develop
    fi

    git checkout master
    numChanges=$(git log --oneline master..origin/master | wc -l | bc)
    if [ $numChanges -gt 0 ]; then
        echo "Unpulled changes found in $dir master."
        git merge origin/master
    fi
    git checkout develop
    #Check number of commits in master but not develop
    numChanges=$(git log --oneline develop..master | wc -l | bc)
    if [ $numChanges -gt 0 ]; then
        echo "Found unmerged changes in $dir master."
        git merge master
        git push
    fi
    popd >/dev/null
done

