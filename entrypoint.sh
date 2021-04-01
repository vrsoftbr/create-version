#!/bin/bash -l

set -euxo pipefail

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk/
JAVA_HOME=/usr/lib/jvm/java-11-openjdk/

if ! [ -z "$DIRECTORY" ]; then
      cd "$DIRECTORY"
fi

BRANCH=$(git branch --show-current)
CHANGELOG="CHANGELOG.md"
export TEMP_FILE="/tmp/log"

# Sets git username and email
sh -c "git config --global user.name '${GITHUB_ACTOR}' \
      && git config --global user.email '${GITHUB_ACTOR}@users.noreply.github.com'"


#Execute build script available through $1 parameter
NEW_TAG=$(bash -c "$SCRIPT")

#Temp file to store commit messages
echo "NEW TAG $NEW_TAG"

#Getting tags and commit messages from repo
LAST_TAG="$(git describe --tags --abbrev=0 || echo "-1")"
echo "Last generated tag -> $LAST_TAG"

COMMIT_COUNT=0

if [ "$LAST_TAG" == "-1" ]; then
    COMMIT_COUNT=1
    (git log --format="- %B" --no-merges | tr '"' ' ') > $TEMP_FILE
else
    COMMIT_COUNT=$(git rev-list $LAST_TAG..HEAD --count)
    (git log --format="- %B" $LAST_TAG... --no-merges | tr '"' ' ') >  $TEMP_FILE
fi


if [ $COMMIT_COUNT -gt 0 ]; then
  echo "Branch $BRANCH has $COMMIT_COUNT new commits"
else 
  echo "Branch $BRANCH doesn't have new commits"
  exit 0
fi


#Creates CHANGELOG.md file if it doesn't exists
if [ ! -f "$CHANGELOG" ]; then
    echo "Creating CHANGELOG.md"
    touch "$CHANGELOG" && git add $CHANGELOG

    echo -e "# CHANGELOG\n\n" > $CHANGELOG
fi

#Update changelog file with the new version and commit messages
sed -i "3s/^/## $NEW_TAG\n\n\n/" CHANGELOG.md
sed -i "4r $TEMP_FILE" CHANGELOG.md

#Add changed files and/or untrancked ones and make the commit
COMMIT_MESSAGE=$(echo "$COMMIT_MESSAGE" | sed "s/:new_version/$NEW_TAG/")
COMMIT_MESSAGE=$(echo "$COMMIT_MESSAGE" | sed "s/:last_version/$LAST_TAG/")


git commit -a -m "$COMMIT_MESSAGE"

COMMIT=$(git log --format="%H" -n 1)

#Push recently created commit
git push origin $BRANCH

pip3 install requests

if [ "$DIRECTORY" != '' ]; then
    python3 /create_tag.py -t $NEW_TAG -c $COMMIT -r "vrsoftbr/$DIRECTORY"
else 
    python3 /create_tag.py -t $NEW_TAG -c $COMMIT -r $GITHUB_REPOSITORY
fi
