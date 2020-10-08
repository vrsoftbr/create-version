#!/bin/sh -l

set -e

echo "Current Folder"
pwd
ls
git branch 

echo  $GITHUB_JOB
echo  $GITHUB_REF
echo  $GITHUB_SHA
echo  $GITHUB_REPOSITORY
echo  $GITHUB_REPOSITORY_OWNER
echo  $GITHUB_RUN_ID
echo  $GITHUB_RUN_NUMBER
echo  $GITHUB_RETENTION_DAYS
echo  $GITHUB_ACTOR
echo  $GITHUB_WORKFLOW
echo  $GITHUB_HEAD_REF
echo  $GITHUB_BASE_REF
echo  $GITHUB_EVENT_NAME
echo  $GITHUB_SERVER_URL
echo  $GITHUB_API_URL
echo  $GITHUB_GRAPHQL_URL
echo  $GITHUB_WORKSPACE
echo  $GITHUB_ACTION
echo  $GITHUB_EVENT_PATH
echo  $GITHUB_PATH
echo  $GITHUB_ENV
echo  $RUNNER_OS
echo  $RUNNER_TOOL_CACHE
echo  $RUNNER_TEMP
echo  $RUNNER_WORKSPACE
echo  $ACTIONS_RUNTIME_URL
echo  $ACTIONS_RUNTIME_TOKEN
echo  $ACTIONS_CACHE_URL


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
