#!/bin/bash -l

set -e

echo "Configuring GIT"
sh -c "git config --global user.name '${GITHUB_ACTOR}' \
      && git config --global user.email '${GITHUB_ACTOR}@users.noreply.github.com'"

CHANGELOG="CHANGELOG.md"

KEY="patch"
FILE=".version"

PATCH=$(sed -rn "s/^$KEY=([^\n]+)$/\1/p" $FILE)
PATCH=$((($PATCH+1)))
echo $PATCH

echo "ATUALIZANDO VERSAO"
sed -ri'' "s/^[#]*\s*${KEY}=.*/$KEY=$PATCH/" $FILE
cat $FILE

while IFS='=' read -r line
do
    line=$(echo $line | tr '.' '_')
    line=$(echo $line | tr -s ' = ' '=')
    line=$(echo $line | tr -d '\r')
    if [ ! -z $line ]
    then
        declare $line
    fi
done <$FILE

echo "VERSAO GERADO"
echo "v${major}.${minor}.${patch}"


NEW_TAG="v${major}.${minor}.${patch}"
git status
TEMP_FILE="/tmp/vr"

git clone --bare $(git remote get-url origin) bare_clone
cd bare_clone
echo "Getting last tag"
LAST_TAG=$(git describe --abbrev=0)

echo "Getting messages log"
git log --format="- %B" $LAST_TAG... --no-merges > $TEMP_FILE
cd ..
rm -rf bare_clone

if [ ! -f "$CHANGELOG" ]; then
    echo "Creating CHANGELOG.md"
    touch "$CHANGELOG"
    echo -e "# CHANGELOG\n\n" > $CHANGELOG
fi


echo "Updating changelog"
sed -i "3s/^/## $NEW_TAG\n\n\n/" CHANGELOG.md
sed -i "4r $TEMP_FILE" CHANGELOG.md

echo "Generating commit"
git add .
git commit -m "Entrega da versão $NEW_TAG"

echo "Creating tag"
git tag -a $NEW_TAG -m "$(cat $TEMP_FILE)"

rm $TEMP_FILE

git push --follow-tags

