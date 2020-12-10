#!/bin/bash -l

set -euxo pipefail

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk/
JAVA_HOME=/usr/lib/jvm/java-11-openjdk/

BRANCH=$(git branch --show-current)
CHANGELOG="CHANGELOG.md"
TEMP_FILE="/tmp/log"

# Sets git username and email
sh -c "git config --global user.name '${GITHUB_ACTOR}' \
      && git config --global user.email '${GITHUB_ACTOR}@users.noreply.github.com'"


#Execute build script available through $1 parameter
NEW_TAG=$(bash -c "$SCRIPT")

#Temp file to store commit messages
echo "NEW TAG $NEW_TAG"

#Getting tags and commit messages from repo
LAST_TAG="$(git describe --abbrev=0 || echo "-1")"
echo "Last generated tag -> $LAST_TAG"

COMMIT_COUNT=0

if [ "$LAST_TAG" == "-1" ]; then
    COMMIT_COUNT=1
    git log --format="- %B" --no-merges > $TEMP_FILE
else
    COMMIT_COUNT=$(git rev-list $LAST_TAG..HEAD --count)
    git log --format="- %B" $LAST_TAG... --no-merges > $TEMP_FILE
fi


if [ $COMMIT_COUNT -gt 0 ]; then
  echo "Branch $BRANCH have $COMMIT_COUNT new commits"
else 
  echo "Branch $BRANCH don't have new commits"
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

git show --pretty=fuller $COMMIT

#Push recently created commit
git push origin $BRANCH

COMMIT=$(git log --format="%H" -n 1)

TAG_MESSAGE="$(cat $TEMP_FILE | sed 's/\"/\\\"/g')"
TAG_MESSAGE="$(echo $TAG_MESSAGE | sed 's/</\\\\</g')"
TAG_MESSAGE="$(echo $TAG_MESSAGE | sed 's/>/\\\\>/g')"

echo "TAG MESSAGE $TAG_MESSAGE"
OUT=$(curl \
  -X POST \
  -H 'authorization: Bearer '"$TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_REPOSITORY/git/tags \
  -d '{"tag":"'"$NEW_TAG"'","message":"'"${TAG_MESSAGE//$'\n'/'\n'}"'","object":"'"$COMMIT"'","type":"commit"}')

TAG_SHA=$(echo $OUT | python3 -c "import sys, json; print(json.load(sys.stdin)['sha'])")

curl \
  -X POST \
  -H 'authorization: Bearer '"$TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$GITHUB_REPOSITORY/git/refs \
  -d '{"ref":"refs/tags/'"$NEW_TAG"'","sha":"'"${TAG_SHA}"'"}'

