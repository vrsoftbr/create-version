#!/bin/sh -l

set -e

echo "Environment"

ls -la

echo  "GITHUB_JOB - $GITHUB_JOB"
echo  "GITHUB_REF - $GITHUB_REF"
echo  "GITHUB_SHA - $GITHUB_SHA"
echo  "GITHUB_REPOSITORY - $GITHUB_REPOSITORY"
echo  "GITHUB_REPOSITORY_OWNER - $GITHUB_REPOSITORY_OWNER"
echo  "GITHUB_RUN_ID - $GITHUB_RUN_ID"
echo  "GITHUB_RUN_NUMBER - $GITHUB_RUN_NUMBER"
echo  "GITHUB_RETENTION_DAYS - $GITHUB_RETENTION_DAYS"
echo  "GITHUB_ACTOR - $GITHUB_ACTOR"
echo  "GITHUB_WORKFLOW - $GITHUB_WORKFLOW"
echo  "GITHUB_HEAD_REF - $GITHUB_HEAD_REF"
echo  "GITHUB_BASE_REF - $GITHUB_BASE_REF"
echo  "GITHUB_EVENT_NAME - $GITHUB_EVENT_NAME"
echo  "GITHUB_SERVER_URL - $GITHUB_SERVER_URL"
echo  "GITHUB_API_URL - $GITHUB_API_URL"
echo  "GITHUB_GRAPHQL_URL - $GITHUB_GRAPHQL_URL"
echo  "GITHUB_WORKSPACE - $GITHUB_WORKSPACE"
echo  "GITHUB_ACTION - $GITHUB_ACTION"
echo  "GITHUB_EVENT_PATH - $GITHUB_EVENT_PATH"
echo  "GITHUB_PATH - $GITHUB_PATH"
echo  "GITHUB_ENV - $GITHUB_ENV"
echo  "RUNNER_OS - $RUNNER_OS"
echo  "RUNNER_TOOL_CACHE - $RUNNER_TOOL_CACHE"
echo  "RUNNER_TEMP - $RUNNER_TEMP"
echo  "RUNNER_WORKSPACE - $RUNNER_WORKSPACE"
echo  "ACTIONS_RUNTIME_URL - $ACTIONS_RUNTIME_URL"
echo  "ACTIONS_RUNTIME_TOKEN - $ACTIONS_RUNTIME_TOKEN"
echo  "ACTIONS_CACHE_URL - $ACTIONS_CACHE_URL"

sh -c "git config --global user.name '${GITHUB_ACTOR}' \
      && git config --global user.email '${GITHUB_ACTOR}@users.noreply.github.com'"


git remote -vv
BRANCH=${GITHUB_REF##*/}
echo "Changing to branch $BRANCH"

git fetch --all
git log --format="- %B" --no-merges && exit 0

CHANGELOG="CHANGELOG.md"
NEW_TAG="$1"

echo "Getting last tag"

LAST_TAG=$(git describe --abbrev=0)
TEMP_FILE="/tmp/vr"

echo  "NEW_TAG - $NEW_TAG" 
echo  "LAST_TAG - $LAST_TAG" 

echo "Configuring GIT"


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
