#! /bin/bash
set -e


CHANGES=0
CHANGES_REPOS=""
UNPUSHED_CHANGES=0
UNPUSHED_REPOS=""

#Update and check for changes
for dir in "." apogee azkaban bolide dementor madeye-common madeye-ops; do
    pushd $dir >/dev/null
    git fetch
    git checkout develop
    #Check for unpushed changes in develop.
    numChanges=$(git log --oneline origin/develop..develop | wc -l | bc)
    if [ $numChanges -gt 0 ]; then
        echo "Unpushed changes found in $dir develop."
        UNPUSHED_CHANGES=1
        UNPUSHED_REPOS="$dir $UNPUSHED_REPOS"
    fi
    #Check for unpulled changes in develop.
    numChanges=$(git log --oneline develop..origin/develop | wc -l | bc)
    if [ $numChanges -gt 0 ]; then
        echo "Unpulled changes found in $dir develop."
        CHANGES=1
        CHANGES_REPOS="$dir $CHANGES_REPOS"
        git merge origin/develop
    fi

    #Check number of commits in master but not develop
    numChanges=$(git log --oneline develop..master | wc -l | bc)
    if [ $numChanges -gt 0 ]; then
        echo "Found unmerged changes in $dir master."
        CHANGES=1
        CHANGES_REPOS="$dir $CHANGES_REPOS"
        git checkout master
        git merge origin/master
        git checkout develop
        git merge master
        git push
    fi
    popd >/dev/null
done

if [ $UNPUSHED_CHANGES -eq 1 ]; then
    echo "You need to push changes in $UNPUSHED_REPOS"
    echo "Please push, test, and try again."
    exit $UNPUSHED_CHANGES
fi

if [ $CHANGES -eq 1 ]; then
    echo "Commits needed for develop found in $CHANGES_REPOS, exiting."
    echo "Please test the new configuration and run again."
    exit $CHANGES
fi

for dir in apogee azkaban bolide dementor madeye-common; do
    pushd $dir >/dev/null
    numChanges=$(git log --oneline master..develop | wc -l | bc)
    if [ $numChanges -gt 0 ]; then
        git checkout master
        git merge develop
        git push
    fi
    popd >/dev/null
done

git checkout master
git merge --no-ff --no-commit develop
bin/init

echo "Please run tests then commit."
echo "If you have modified any files in madeye-ops, please push those to production."
echo "(For example, /etc/init/*.conf scripts, nginx configurations, etc)"
