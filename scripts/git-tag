#!/bin/bash

validate() {
    validation=$(echo "$1" | grep -oE '^v([0-9])\.([0-9])\.([0-9])$')
    if [ -z "$validation" ]
    then
        echo "error previous tag \"$1\" invalid format: expected vX.X.X"
        exit 1
    fi
}

tag=$(git describe --abbrev=0 --tags 2>/dev/null || echo v0.0.0)
validate "$tag"

tag=${tag:1}

IFS='.' read -r -a numbers <<< "$tag"

major=v$((numbers[0]+1)).0.0
minor=v${numbers[0]}.$((numbers[1]+1)).0
bugfix=v${numbers[0]}.${numbers[1]}.$((numbers[2]+1))

PS3="Choose a tag to apply:"

result=("$major" "$minor" "$bugfix")
select version in "${major} - major" "${minor} - minor" "${bugfix} - bugfix"
do
    if [ -z "$version" ]
    then
        continue  
    fi
    tag=${result[$((REPLY-1))]}
    break
done

printf "Describe your tag:"
read -r tag_description

git tag -a "$tag" -m "$tag_description" && echo "Done! Tag successfuly applied"

