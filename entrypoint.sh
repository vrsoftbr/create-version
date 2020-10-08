#!/bin/sh -l

set -e

echo "Current Folder"
pwd
ls


CHANGELOG="CHANGELOG.md"
NEW_TAG="$1"

echo "Getting last tag"
LAST_TAG=$(git describe --abbrev=0)
TEMP_FILE="/tmp/vr"

echo "Configuring GIT"

sh -c "git config --global user.name '${GITHUB_ACTOR}' \
      && git config --global user.email '${GITHUB_ACTOR}@users.noreply.github.com'"

if [ ! -f "$CHANGELOG" ]; then
    echo "Creating CHANGELOG.md"
    touch "$CHANGELOG"
    echo -e "# CHANGELOG\n\n" > $CHANGELOG
fi


echo "Getting messages log"
git log --format="- %s" $LAST_TAG... --no-merges > $TEMP_FILE


echo "Updating changelog"
sed -i "3s/^/## $NEW_TAG\n\n\n/" CHANGELOG.md
sed -i "4r temp" CHANGELOG.md

echo "Generating commit"
git commit -a -m "Entrega da versão $NEW_TAG"

echo "Creating tag"
git tag -a $NEW_TAG -m "$(cat $TEMP_FILE)"

git push --follow-tags

rm $TEMP_FILE
