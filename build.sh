#!/bin/bash

KEY="patch"
FILE=".version"

PATCH=$(sed -rn "s/^$KEY=([^\n]+)$/\1/p" $FILE)
PATCH=$((($PATCH+1)))

sed -ri'' "s/^[#]*\s*${KEY}=.*/$KEY=$PATCH/" $FILE

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

echo "v${major}.${minor}.${patch}"