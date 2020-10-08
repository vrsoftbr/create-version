#!/bin/bash -l

set -e

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk/
JAVA_HOME=/usr/lib/jvm/java-11-openjdk/

# Sets git username and email
sh -c "git config --global user.name '${GITHUB_ACTOR}' \
      && git config --global user.email '${GITHUB_ACTOR}@users.noreply.github.com'"

CHANGELOG="CHANGELOG.md"

#Execute build script available through $1 parameter
NEW_TAG=$(bash -c "$1")
#Temp file to store commit messages
TEMP_FILE="/tmp/log"
BARE="/tmp/bare"

#Bare clone to get last tag and all the commits since that tag
git clone --bare $(git remote get-url origin) $BARE
#Getting tags and commit messages from bare repo
LAST_TAG=$(git -C $BARE describe --abbrev=0 || echo "-1")
if [ $LAST_TAG -eq "-1" ]; then
    git -C $BARE log --format="- %B" --no-merges > $TEMP_FILE
else
    git -C $BARE log --format="- %B" $LAST_TAG... --no-merges > $TEMP_FILE
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

#Create the new tag
git tag -a $NEW_TAG -m "$(cat $TEMP_FILE)"

#Push recently created commit along with tags
git push --follow-tags

