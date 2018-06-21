#!/usr/bin/env bash

set -e

tags="$(git tag | grep "$jira_project_prefix[0-9]{0,5}_.*" -E -o)"

tags=($(echo "$tags" | tr ' ' '\n'))

last_index=0
for (( i=0 ; i<${#tags[*]} ; ++i ))
do
tag_elements=($(echo "${tags[$i]}" | tr '_' '\n'))

tags_list[$last_index]="${tag_elements[0]}"

tag_title=""

for (( j=1 ; j<${#tag_elements[*]} ; ++j ))
do
tag_title+="${tag_elements[$j]}"

if (( j < ${#tag_elements[*]} - 1 ))
then
tag_title+=" "
fi
done

last_index=$((last_index + 1))
tags_list[$last_index]="$tag_title"

last_index=$((last_index + 1))
done

epics=""

for (( i=0 ; i<${#tags_list[*]} ; i+=2 ))
do

epics+="${tags_list[$((i + 1))]}"$'\n'$'\n'$'\t'"$jira_default_url${tags_list[$i]}"
if (( i < ${#tags_list[*]} - 1 ))
then
epics+=$'\n'$'\n'
fi

done

envman add --key EPICS_FROM_TAGS --value "$epics"

echo "Epics featured:"
echo ""
envman run bash -c 'echo "$EPICS_FROM_TAGS"'

JIRA_ESCAPED_URL=$(echo ${jira_project_prefix} | sed -e "s#/#\\\/#g")

git log --pretty=format:"%s" | grep "$jira_default_url[0-9]{0,5}" -o -E | sort -u -r | sed -e 's/^/'${JIRA_ESCAPED_URL}'/' | envman add --key FEATURES_FROM_COMMITS

echo "Features:"
echo ""
envman run bash -c 'echo "$FEATURES_FROM_COMMITS"'
