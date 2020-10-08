#!/bin/sh -l

set -e

CHANGELOG="CHANGELOG.md"
NEW_TAG="$1"
LAST_TAG=$(git describe --abbrev=0)
TEMP_FILE="/tmp/vr"

sh -c "git config --global user.name '${GITHUB_ACTOR}' \
      && git config --global user.email '${GITHUB_ACTOR}@users.noreply.github.com'

if [ ! -f "$CHANGELOG" ]; then
    touch "$CHANGELOG"
    echo -e "# CHANGELOG\n\n" > $CHANGELOG
fi

git log --format="- %s" $LAST_TAG... --no-merges > $TEMP_FILE

sed -i "3s/^/## $NEW_TAG\n\n\n/" CHANGELOG.md

sed -i "4r temp" CHANGELOG.md

git commit -a -m "Entrega da versão $NEW_TAG"
git tag -a $NEW_TAG -m "$(cat $TEMP_FILE)"

git push --follow-tags

rm $TEMP_FILE
