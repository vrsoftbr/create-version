#!/bin/bash -l

set -e

# Sets git username and email
sh -c "git config --global user.name '${GITHUB_ACTOR}' \
      && git config --global user.email '${GITHUB_ACTOR}@users.noreply.github.com'"

CHANGELOG="CHANGELOG.md"

#Execute build script available through $1 parameter
NEW_TAG=$(bash -c "$1")

echo "NEW TAG $NEW_TAG"

#Temp file to store commit messages
TEMP_FILE="/tmp/log"
BARE="/tmp/bare"

#Bare clone to get last tag and all the commits since that tag
git clone --bare $(git remote get-url origin) $BARE
#Getting tags and commit messages from bare repo
LAST_TAG="$(git -C $BARE describe --abbrev=0 || echo "-1")"
if [ "$LAST_TAG" == "-1" ]; then
    (git -C $BARE log --format="- %B" --no-merges | tr '"' ' ') > $TEMP_FILE
else
    (git -C $BARE log --format="- %B" $LAST_TAG... --no-merges | tr '"' ' ') > $TEMP_FILE
fi

#Creates CHANGELOG.md file if it doesn't exists
if [ ! -f "$CHANGELOG" ]; then
    echo "Creating CHANGELOG.md"
    touch "$CHANGELOG"

    echo -e "# CHANGELOG\n\n" > $CHANGELOG
fi

#Update changelog file with the new version and commit messages
sed -i "3s/^/## $NEW_TAG\n\n\n/" CHANGELOG.md
sed -i "4r $TEMP_FILE" CHANGELOG.md

#Add new and changed files and makes a commit
git add .
git commit -m "Entrega da versão $NEW_TAG"

#Push recently created commit along with tags
git push

COMMIT=$(git log --format="%H" -n 1)

TAG_MESSAGE="$(cat $TEMP_FILE)"
echo "$TAG_MESSAGE"
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

